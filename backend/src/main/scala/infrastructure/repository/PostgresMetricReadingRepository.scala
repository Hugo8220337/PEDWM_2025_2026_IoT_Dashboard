package infrastructure.repository

import doobie.*
import doobie.implicits.*
import doobie.postgres.implicits.*
import domain.model.MetricReading
import domain.repository.MetricReadingRepository
import aspect.LoggingAspect
import zio.*
import zio.interop.catz.*
import java.util.UUID

class PostgresMetricReadingRepository(xa: Transactor[Task]) extends MetricReadingRepository:

  def insert(reading: MetricReading): Task[MetricReading] =
    sql"""
      INSERT INTO metric_reading (id, sensor_id, timestamp, value)
      VALUES (${reading.id}, ${reading.sensorId}, ${reading.timestamp}, ${reading.value})
    """.update.run.transact(xa).as(reading) @@
      LoggingAspect.timed(s"MetricReadingRepository.insert[sensor=${reading.sensorId}]")

  def findBySensor(sensorId: UUID, limit: Int): Task[List[MetricReading]] =
    sql"""
      SELECT id, sensor_id, timestamp, value
      FROM metric_reading
      WHERE sensor_id = $sensorId
      ORDER BY timestamp DESC
      LIMIT $limit
    """.query[MetricReading].to[List].transact(xa) @@
      LoggingAspect.timed(s"MetricReadingRepository.findBySensor[$sensorId limit=$limit]")

object PostgresMetricReadingRepository:
  val layer: URLayer[Transactor[Task], MetricReadingRepository] =
    ZLayer(ZIO.service[Transactor[Task]].map(PostgresMetricReadingRepository(_)))
