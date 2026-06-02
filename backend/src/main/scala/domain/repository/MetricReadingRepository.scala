package domain.repository

import zio.Task
import domain.model.MetricReading
import java.util.UUID

trait MetricReadingRepository:
  def insert(reading: MetricReading): Task[MetricReading]
  def findBySensor(sensorId: UUID, limit: Int): Task[List[MetricReading]]
