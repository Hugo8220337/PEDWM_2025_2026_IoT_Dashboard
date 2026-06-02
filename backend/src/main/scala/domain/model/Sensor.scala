package domain.model

import java.util.UUID
import java.time.Instant
import doobie.{Read, Write}

case class Sensor(
  id: UUID,
  groupId: String,
  nodeId: String,
  sensorName: String,
  variableName: String,
  dataType: String,
  discoveredAt: Instant,
  isAvailable: Boolean
)

object Sensor:
  import doobie.postgres.implicits.*
  given Read[Sensor]  = Read.derived
  given Write[Sensor] = Write.derived
