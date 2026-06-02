package infrastructure.memory

import application.port.MetricBroadcast
import domain.model.MetricReceived
import zio.*
import zio.stream.*

class InMemoryMetricBroadcast(hub: Hub[MetricReceived]) extends MetricBroadcast:

  def publish(event: MetricReceived): UIO[Unit] =
    hub.publish(event).unit

  def subscribe: ZStream[Any, Nothing, MetricReceived] =
    ZStream.fromHub(hub)

object InMemoryMetricBroadcast:
  val layer: ULayer[MetricBroadcast] =
    ZLayer(Hub.unbounded[MetricReceived].map(InMemoryMetricBroadcast(_)))
