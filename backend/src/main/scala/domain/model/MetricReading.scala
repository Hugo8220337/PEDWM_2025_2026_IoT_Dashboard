package domain.model

import java.util.UUID
import java.time.Instant
import doobie.{Read, Write}

case class MetricReading(
  id: UUID,
  sensorId: UUID,
  timestamp: Instant,
  value: Double
)

object MetricReading:
  import doobie.postgres.implicits.*
  given Read[MetricReading]  = Read.derived
  given Write[MetricReading] = Write.derived
