package infrastructure.config

import zio.*

object LogConfig:

  val level: LogLevel =
    sys.env.getOrElse("LOG_LEVEL", "INFO").toUpperCase match
      case "TRACE" => LogLevel.Trace
      case "DEBUG" => LogLevel.Debug
      case "WARN"  => LogLevel.Warning
      case "ERROR" => LogLevel.Error
      case _       => LogLevel.Info
