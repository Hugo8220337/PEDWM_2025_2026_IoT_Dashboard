package infrastructure.graphql

import application.port.MetricBroadcast
import caliban.*
import caliban.schema.Schema.auto.*
import caliban.schema.ArgBuilder.auto.*
import domain.model.{MetricReading, MetricReceived, Sensor}
import domain.repository.{MetricReadingRepository, SensorRepository}
import zio.*
import zio.stream.*

import java.util.UUID

case class SensorView(
    id: String,
    groupId: String,
    nodeId: String,
    sensorName: String,
    variableName: String,
    dataType: String,
    isAvailable: Boolean
)

case class ReadingView(
    id: String,
    sensorId: String,
    timestamp: Long,
    value: Double
)

case class NodeView(
    nodeId: String,
    isAvailable: Boolean,
    sensors: List[SensorView]
)

case class SensorsArgs(groupId: String, nodeId: String)
case class ReadingsArgs(sensorId: String, limit: Int = 100)
case class LiveReadingsArgs(sensorId: String)

case class Queries(
    nodes: Task[List[NodeView]],
    sensors: SensorsArgs => Task[List[SensorView]],
    readings: ReadingsArgs => Task[List[ReadingView]]
)

case class Subscriptions(
    liveReadings: LiveReadingsArgs => ZStream[Any, Nothing, ReadingView]
)

class GraphQLApi(
    sensorRepo: SensorRepository,
    readingRepo: MetricReadingRepository,
    broadcast: MetricBroadcast
):
  private def toView(s: Sensor): SensorView =
    SensorView(
      s.id.toString,
      s.groupId,
      s.nodeId,
      s.sensorName,
      s.variableName,
      s.dataType,
      s.isAvailable
    )

  private def toView(r: MetricReading): ReadingView =
    ReadingView(
      r.id.toString,
      r.sensorId.toString,
      r.timestamp.toEpochMilli,
      r.value
    )

  private def toView(e: MetricReceived): ReadingView =
    ReadingView(
      e.sensor.id.toString,
      e.sensor.id.toString,
      e.timestamp,
      e.value
    )

  private def allNodes: Task[List[NodeView]] =
    sensorRepo.findAll.map(
      _.groupBy(_.nodeId)
        .map { (nodeId, sensors) =>
          NodeView(nodeId, sensors.exists(_.isAvailable), sensors.map(toView))
        }
        .toList
        .sortBy(_.nodeId)
    )

  val api: GraphQL[Any] = graphQL(
    new RootResolver[Queries, Unit, Subscriptions](
      Some(Queries(
        nodes = allNodes,
        sensors = args =>
          sensorRepo.findByNode(args.groupId, args.nodeId).map(_.map(toView)),
        readings = args =>
          readingRepo
            .findBySensor(UUID.fromString(args.sensorId), args.limit)
            .map(_.map(toView))
      )),
      None,
      Some(Subscriptions(
        liveReadings = args =>
          broadcast.subscribe
            .filter(_.sensor.id.toString == args.sensorId)
            .map(toView)
      ))
    )
  )

object GraphQLApi:
  val layer: URLayer[
    SensorRepository & MetricReadingRepository & MetricBroadcast,
    GraphQLApi
  ] =
    ZLayer {
      for
        sensorRepo <- ZIO.service[SensorRepository]
        readingRepo <- ZIO.service[MetricReadingRepository]
        broadcast <- ZIO.service[MetricBroadcast]
      yield GraphQLApi(sensorRepo, readingRepo, broadcast)
    }
