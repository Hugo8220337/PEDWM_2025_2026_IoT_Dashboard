package infrastructure.repository

import doobie.*
import doobie.implicits.*
import doobie.postgres.implicits.*
import domain.model.Sensor
import domain.repository.SensorRepository
import aspect.LoggingAspect
import zio.*
import zio.interop.catz.*

class PostgresSensorRepository(xa: Transactor[Task]) extends SensorRepository:

  def upsert(sensor: Sensor): Task[Sensor] =
    sql"""
      INSERT INTO sensor (id, group_id, node_id, sensor_name, variable_name, data_type, discovered_at, is_available)
      VALUES (${sensor.id}, ${sensor.groupId}, ${sensor.nodeId}, ${sensor.sensorName},
              ${sensor.variableName}, ${sensor.dataType}, ${sensor.discoveredAt}, true)
      ON CONFLICT (group_id, node_id, sensor_name, variable_name)
      DO UPDATE SET data_type = EXCLUDED.data_type, is_available = true
      RETURNING id, group_id, node_id, sensor_name, variable_name, data_type, discovered_at, is_available
    """.query[Sensor].unique.transact(xa) @@
      LoggingAspect.timed(s"SensorRepository.upsert[${sensor.sensorName}/${sensor.variableName}]")

  def findByNode(groupId: String, nodeId: String): Task[List[Sensor]] =
    sql"""
      SELECT id, group_id, node_id, sensor_name, variable_name, data_type, discovered_at, is_available
      FROM sensor
      WHERE group_id = $groupId AND node_id = $nodeId
    """.query[Sensor].to[List].transact(xa) @@
      LoggingAspect.timed(s"SensorRepository.findByNode[$groupId/$nodeId]")

  def findAll: Task[List[Sensor]] =
    sql"""
      SELECT id, group_id, node_id, sensor_name, variable_name, data_type, discovered_at, is_available
      FROM sensor
    """.query[Sensor].to[List].transact(xa) @@
      LoggingAspect.timed("SensorRepository.findAll")

  def setAvailability(groupId: String, nodeId: String, available: Boolean): Task[Unit] =
    sql"""
      UPDATE sensor SET is_available = $available
      WHERE group_id = $groupId AND node_id = $nodeId
    """.update.run.transact(xa).unit @@
      LoggingAspect.timed(s"SensorRepository.setAvailability[$groupId/$nodeId available=$available]")

object PostgresSensorRepository:
  val layer: URLayer[Transactor[Task], SensorRepository] =
    ZLayer(ZIO.service[Transactor[Task]].map(PostgresSensorRepository(_)))
