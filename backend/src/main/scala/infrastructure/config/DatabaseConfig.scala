package infrastructure.config

import zio.*

case class DatabaseConfig(
  url: String,
  user: String,
  password: String,
  maxPoolSize: Int = 10
)

object DatabaseConfig:
  val layer: ULayer[DatabaseConfig] =
    ZLayer.succeed(DatabaseConfig(
      url         = sys.env.getOrElse("DB_URL",      "jdbc:postgresql://localhost:5432/pedwm"),
      user        = sys.env.getOrElse("DB_USER",     "postgres"),
      password    = sys.env.getOrElse("DB_PASSWORD", "postgres")
    ))
