package application.port

import domain.model.MetricReceived
import zio.*
import zio.stream.*

trait MetricBroadcast:
  def publish(event: MetricReceived): UIO[Unit]
  def subscribe: ZStream[Any, Nothing, MetricReceived]
