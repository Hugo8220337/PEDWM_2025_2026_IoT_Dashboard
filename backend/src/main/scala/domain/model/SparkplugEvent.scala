package domain.model

sealed trait SparkplugEvent

case class NodeDiscovered(groupId: String, nodeId: String, sensors: List[Sensor]) extends SparkplugEvent
case class MetricReceived(sensor: Sensor, value: Double, timestamp: Long)          extends SparkplugEvent
case class NodeLost(groupId: String, nodeId: String)                               extends SparkplugEvent
