package application.port

import domain.model.Sensor
import zio.Task

trait NodeRegistry:
  def register(groupId: String, nodeId: String, sensors: List[Sensor]): Task[Unit]
  def resolve(groupId: String, nodeId: String, metricName: String): Task[Option[Sensor]]
  def remove(groupId: String, nodeId: String): Task[Unit]
