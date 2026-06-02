package application.usecase

import application.port.{NodeRegistry, RawMqttMessage}
import domain.model.{MetricReading, MetricReceived, NodeDiscovered, NodeLost, Sensor, SparkplugEvent}
import aspect.LoggingAspect
import infrastructure.sparkplug.{MessageType, SparkplugDecoder, SparkplugTopic}
import org.eclipse.tahu.protobuf.sparkplug_b.{DataType, Payload}
import zio.*

import java.time.Instant
import java.util.UUID

class SparkplugMessageProcessor(registry: NodeRegistry) extends MessageProcessor:

  def process(msg: RawMqttMessage): Task[List[SparkplugEvent]] =
    SparkplugTopic.parse(msg.topic) match
      case None =>
        ZIO.logDebug(s"Ignoring non-SparkplugB topic: ${msg.topic}").as(Nil)
      case Some(topic) =>
        route(msg, topic) @@ LoggingAspect.timed(s"MessageProcessor.process[${msg.topic}]")

  private def route(msg: RawMqttMessage, topic: SparkplugTopic): Task[List[SparkplugEvent]] =
    SparkplugDecoder.decode(msg.payload) match
      case Left(err) =>
        ZIO.logWarning(s"Failed to decode ${msg.topic}: ${err.getMessage}").as(Nil)
      case Right(payload) =>
        topic.messageType match
          case MessageType.NBirth => handleNBirth(topic, payload)
          case MessageType.NData  => handleNData(topic, payload)
          case MessageType.NDeath => handleNDeath(topic)
          case _                  => ZIO.succeed(Nil)

  private def handleNBirth(topic: SparkplugTopic, payload: Payload): Task[List[SparkplugEvent]] =
    val candidates = payload.metrics.toList.flatMap { metric =>
      metric.name.flatMap(parseSensorName).map { (sensorName, variableName) =>
        Sensor(
          id           = UUID.randomUUID(),
          groupId      = topic.groupId,
          nodeId       = topic.nodeId,
          sensorName   = sensorName,
          variableName = variableName,
          dataType     = metric.datatype.map(DataType.fromValue(_).name).getOrElse("Unknown"),
          discoveredAt = Instant.now(),
          isAvailable  = true
        )
      }
    }
    registry.register(topic.groupId, topic.nodeId, candidates)
      .as(List(NodeDiscovered(topic.groupId, topic.nodeId, candidates)))

  private def handleNData(topic: SparkplugTopic, payload: Payload): Task[List[SparkplugEvent]] =
    ZIO.foreach(payload.metrics.toList) { metric =>
      val resolve = metric.name match
        case Some(name) => registry.resolve(topic.groupId, topic.nodeId, name)
        case None       => ZIO.succeed(None)
      resolve.flatMap {
        case None =>
          ZIO.logWarning(s"Metric dropped no registered sensor for ${metric.name.getOrElse("?")} in ${topic.groupId}/${topic.nodeId}").as(None)
        case Some(sensor) =>
          ZIO.succeed(extractValue(metric).map(MetricReceived(sensor, _, metric.timestamp.getOrElse(0L))))
      }
    }.map(_.flatten)

  private def handleNDeath(topic: SparkplugTopic): Task[List[SparkplugEvent]] =
    registry.remove(topic.groupId, topic.nodeId)
      .as(List(NodeLost(topic.groupId, topic.nodeId)))

  private def parseSensorName(name: String): Option[(String, String)] =
    name.split("/", 2) match
      case Array(sensor, variable) => Some((sensor, variable))
      case _                       => None

  private def extractValue(metric: Payload.Metric): Option[Double] =
    import Payload.Metric.Value.*
    metric.value match
      case IntValue(v)     => Some(v.toDouble)
      case LongValue(v)    => Some(v.toDouble)
      case FloatValue(v)   => Some(v.toDouble)
      case DoubleValue(v)  => Some(v)
      case BooleanValue(v) => Some(if v then 1.0 else 0.0)
      case _               => None

object SparkplugMessageProcessor:
  val layer: URLayer[NodeRegistry, MessageProcessor] =
    ZLayer(ZIO.service[NodeRegistry].map(SparkplugMessageProcessor(_)))
