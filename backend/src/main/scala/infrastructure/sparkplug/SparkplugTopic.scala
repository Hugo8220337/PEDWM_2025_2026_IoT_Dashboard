package infrastructure.sparkplug

enum MessageType:
  case NBirth, NDeath, NData, DBirth, DDeath, DData, NCmd, DCmd

case class SparkplugTopic(
  groupId:     String,
  messageType: MessageType,
  nodeId:      String,
  deviceId:    Option[String] = None
)

object SparkplugTopic:
  def parse(topic: String): Option[SparkplugTopic] =
    topic.split("/").toList match
      case "spBv1.0" :: group :: msgType :: node :: rest =>
        toMessageType(msgType).map(SparkplugTopic(group, _, node, rest.headOption))
      case _ => None

  private def toMessageType(s: String): Option[MessageType] = s match
    case "NBIRTH" => Some(MessageType.NBirth)
    case "NDEATH" => Some(MessageType.NDeath)
    case "NDATA"  => Some(MessageType.NData)
    case "DBIRTH" => Some(MessageType.DBirth)
    case "DDEATH" => Some(MessageType.DDeath)
    case "DDATA"  => Some(MessageType.DData)
    case "NCMD"   => Some(MessageType.NCmd)
    case "DCMD"   => Some(MessageType.DCmd)
    case _        => None
