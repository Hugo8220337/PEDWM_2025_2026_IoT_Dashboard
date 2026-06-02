package aspect

import zio.*

object LoggingAspect:

  private val slowThresholdMs = 200L

  def timed(label: String): ZIOAspect[Nothing, Any, Nothing, Any, Nothing, Any] =
    new ZIOAspect[Nothing, Any, Nothing, Any, Nothing, Any]:
      override def apply[R, E, A](zio: ZIO[R, E, A])(implicit trace: Trace): ZIO[R, E, A] =
        for
          start  <- Clock.nanoTime
          result <- zio.tapError(e =>
                      Clock.nanoTime.flatMap(end =>
                        ZIO.logError(s"[LOG] $label failed in ${ms(start, end)}ms $e")
                      )
                    )
          end    <- Clock.nanoTime
          elapsed = ms(start, end)
          _      <- if elapsed >= slowThresholdMs
                    then ZIO.logWarning(s"[LOG] $label slow: ${elapsed}ms")
                    else ZIO.logDebug(s"[LOG] $label completed in ${elapsed}ms")
        yield result

  private def ms(start: Long, end: Long): Long = (end - start) / 1_000_000
