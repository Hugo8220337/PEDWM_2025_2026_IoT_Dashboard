package infrastructure.memory

import domain.model.Sensor
import application.port.NodeRegistry
import domain.repository.SensorRepository
import aspect.LoggingAspect
import zio.*

class InMemoryNodeRegistry(
  index:      Ref[Map[(String, String), Map[String, Sensor]]],
  sensorRepo: SensorRepository
) extends NodeRegistry:

  def register(groupId: String, nodeId: String, sensors: List[Sensor]): Task[Unit] =
    val key = (groupId, nodeId)
    (for
      persisted <- ZIO.foreach(sensors)(sensorRepo.upsert)
      byName     = persisted.map(s => s"${s.sensorName}/${s.variableName}" -> s).toMap
      _         <- index.update(_.updated(key, byName))
    yield ()) @@ LoggingAspect.timed(s"NodeRegistry.register[$groupId/$nodeId count=${sensors.size}]")

  def resolve(groupId: String, nodeId: String, metricName: String): Task[Option[Sensor]] =
    index.get.map(_.get((groupId, nodeId)).flatMap(_.get(metricName))) @@
      LoggingAspect.timed(s"NodeRegistry.resolve[$groupId/$nodeId name=$metricName]")

  def remove(groupId: String, nodeId: String): Task[Unit] =
    val key = (groupId, nodeId)
    (index.update(_ - key) *> sensorRepo.setAvailability(groupId, nodeId, available = false)) @@
      LoggingAspect.timed(s"NodeRegistry.remove[$groupId/$nodeId]")

object InMemoryNodeRegistry:
  val layer: ZLayer[SensorRepository, Throwable, NodeRegistry] =
    ZLayer {
      for
        sensorRepo <- ZIO.service[SensorRepository]
        allSensors <- sensorRepo.findAll
        byName      = allSensors
                        .groupBy(s => (s.groupId, s.nodeId))
                        .view.mapValues(ss => ss.map(s => s"${s.sensorName}/${s.variableName}" -> s).toMap)
                        .toMap
        index      <- Ref.make(byName)
      yield InMemoryNodeRegistry(index, sensorRepo)
    }
