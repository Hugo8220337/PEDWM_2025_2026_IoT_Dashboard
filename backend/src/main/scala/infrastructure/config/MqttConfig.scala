package infrastructure.config

import zio.*

case class MqttConfig(
  brokerUrl: String,
  clientId: String
)

object MqttConfig:
  val layer: ULayer[MqttConfig] =
    ZLayer.succeed(MqttConfig(
      brokerUrl = sys.env.getOrElse("MQTT_BROKER_URL", "tcp://localhost:1883"),
      clientId  = sys.env.getOrElse("MQTT_CLIENT_ID",  "pedwm-backend")
    ))
