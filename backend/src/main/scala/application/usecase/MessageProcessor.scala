package application.usecase

import application.port.RawMqttMessage
import domain.model.SparkplugEvent
import zio.Task

trait MessageProcessor:
  def process(msg: RawMqttMessage): Task[List[SparkplugEvent]]
