package infrastructure.mqtt

import application.port.RawMqttMessage
import infrastructure.config.MqttConfig
import org.eclipse.paho.client.mqttv3.*
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence
import zio.*
import zio.stream.*

class MqttSubscriber private (queue: Queue[RawMqttMessage]):
  val messages: ZStream[Any, Nothing, RawMqttMessage] = ZStream.fromQueue(queue)

object MqttSubscriber:

  val layer: ZLayer[MqttConfig, Throwable, MqttSubscriber] =
    ZLayer.scoped {
      for
        config  <- ZIO.service[MqttConfig]
        queue   <- Queue.unbounded[RawMqttMessage]
        runtime <- ZIO.runtime[Any]
        _       <- ZIO.acquireRelease(connect(config, queue, runtime))(disconnect)
      yield MqttSubscriber(queue)
    }

  private def connect(
    config: MqttConfig,
    queue: Queue[RawMqttMessage],
    runtime: Runtime[Any]
  ): Task[MqttClient] =
    ZIO.attempt {
      val client = new MqttClient(config.brokerUrl, config.clientId, new MemoryPersistence())
      val opts   = new MqttConnectOptions()
      opts.setCleanSession(true)
      opts.setAutomaticReconnect(true)
      client.connect(opts)
      client.setCallback(new MqttCallback {
        def messageArrived(topic: String, msg: MqttMessage): Unit =
          Unsafe.unsafe { implicit u =>
            runtime.unsafe.run(
              queue.offer(RawMqttMessage(topic, msg.getPayload.clone())).unit
            )
          }
        def connectionLost(cause: Throwable): Unit =
          Unsafe.unsafe { implicit u =>
            runtime.unsafe.run(ZIO.logWarning(s"MQTT connection lost: ${cause.getMessage}").unit)
          }
        def deliveryComplete(token: IMqttDeliveryToken): Unit = ()
      })
      client.subscribe("spBv1.0/#")
      client
    }

  private def disconnect(client: MqttClient): UIO[Unit] =
    ZIO.attempt(client.disconnect()).orDie
