package application.port

case class RawMqttMessage(topic: String, payload: Array[Byte])
