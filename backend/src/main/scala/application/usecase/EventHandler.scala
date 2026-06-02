package application.usecase

import domain.model.SparkplugEvent
import zio.Task

trait EventHandler:
  def handle(event: SparkplugEvent): Task[Unit]
