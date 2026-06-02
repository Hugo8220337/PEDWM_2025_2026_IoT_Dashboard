package infrastructure.sparkplug

import org.eclipse.tahu.protobuf.sparkplug_b.Payload

import scala.util.Try

object SparkplugDecoder:
  def decode(bytes: Array[Byte]): Either[Throwable, Payload] =
    Try(Payload.parseFrom(bytes)).toEither
