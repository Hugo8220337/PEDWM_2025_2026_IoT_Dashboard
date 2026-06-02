package application.usecase

import application.port.MetricBroadcast
import domain.model.*
import domain.repository.MetricReadingRepository
import aspect.LoggingAspect
import zio.*

import java.time.Instant
import java.util.UUID

class SparkplugEventHandler(metricReadingRepo: MetricReadingRepository, broadcast: MetricBroadcast) extends EventHandler:

  def handle(event: SparkplugEvent): Task[Unit] =
    (logEvent(event) *> dispatch(event)) @@ LoggingAspect.timed(s"EventHandler.handle[${eventLabel(event)}]")

  private def dispatch(event: SparkplugEvent): Task[Unit] =
    event match
      case NodeDiscovered(_, _, _) => ZIO.unit

      case event @ MetricReceived(sensor, value, timestamp) =>
        metricReadingRepo.insert(MetricReading(
          id        = UUID.randomUUID(),
          sensorId  = sensor.id,
          timestamp = Instant.ofEpochMilli(timestamp),
          value     = value
        )).unit *> broadcast.publish(event)

      case NodeLost(_, _) => ZIO.unit

  private def logEvent(event: SparkplugEvent): UIO[Unit] =
    event match
      case NodeDiscovered(groupId, nodeId, sensors) =>
        ZIO.logInfo(s"Node discovered: $groupId/$nodeId ${sensors.size} sensors registered")
      case MetricReceived(sensor, value, _) =>
        ZIO.logDebug(s"${sensor.groupId}/${sensor.nodeId} ${sensor.sensorName}/${sensor.variableName} = $value")
      case NodeLost(groupId, nodeId) =>
        ZIO.logInfo(s"Node lost: $groupId/$nodeId")

  private def eventLabel(event: SparkplugEvent): String = event match
    case NodeDiscovered(g, n, _) => s"NodeDiscovered $g/$n"
    case MetricReceived(s, _, _) => s"MetricReceived ${s.sensorName}/${s.variableName}"
    case NodeLost(g, n)          => s"NodeLost $g/$n"

object SparkplugEventHandler:
  val layer: URLayer[MetricReadingRepository & MetricBroadcast, EventHandler] =
    ZLayer {
      for
        repo      <- ZIO.service[MetricReadingRepository]
        broadcast <- ZIO.service[MetricBroadcast]
      yield SparkplugEventHandler(repo, broadcast)
    }
