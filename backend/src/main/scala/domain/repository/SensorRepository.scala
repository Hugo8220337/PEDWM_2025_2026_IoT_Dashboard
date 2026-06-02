package domain.repository

import zio.Task
import domain.model.Sensor
import java.util.UUID

trait SensorRepository:
  def upsert(sensor: Sensor): Task[Sensor]
  def findByNode(groupId: String, nodeId: String): Task[List[Sensor]]
  def findAll: Task[List[Sensor]]
  def setAvailability(groupId: String, nodeId: String, available: Boolean): Task[Unit]
