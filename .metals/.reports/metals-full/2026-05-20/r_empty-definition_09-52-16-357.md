error id: file://<WORKSPACE>/backend/src/main/scala/Main.scala:
file://<WORKSPACE>/backend/src/main/scala/Main.scala
empty definition using pc, found symbol in pc: 
empty definition using semanticdb
empty definition using fallback
non-local guesses:
	 -infrastructure/graphql/GraphQLApi.
	 -zio/GraphQLApi.
	 -zio/stream/GraphQLApi.
	 -GraphQLApi.
	 -scala/Predef.GraphQLApi.
offset: 900
uri: file://<WORKSPACE>/backend/src/main/scala/Main.scala
text:
```scala
import application.usecase.{EventHandler, SparkplugEventHandler, MessageProcessor, SparkplugMessageProcessor}
import infrastructure.config.{DatabaseConfig, LogConfig, MqttConfig}
import infrastructure.database.Database
import infrastructure.graphql.{GraphQLApi, GraphQLServer}
import infrastructure.memory.{InMemoryNodeRegistry, InMemoryMetricBroadcast}
import infrastructure.mqtt.MqttSubscriber
import infrastructure.repository.{PostgresSensorRepository, PostgresMetricReadingRepository}
import zio.*
import zio.stream.*

object Main extends ZIOAppDefault:

  override def run: ZIO[Any, Any, Any] =
    ZIO.logLevel(LogConfig.level) {
      program.provide(
        DatabaseConfig.layer,
        Database.transactorLayer,
        PostgresSensorRepository.layer,
        PostgresMetricReadingRepository.layer,
        InMemoryNodeRegistry.layer,
        InMemoryMetricBroadcast.layer,
        GraphQL@@Api.layer,
        MqttConfig.layer,
        MqttSubscriber.layer,
        SparkplugMessageProcessor.layer,
        SparkplugEventHandler.layer
      )
    }

  private val program =
    for
      _ <- ZIO.serviceWithZIO[GraphQLApi](_.api.interpreter.orDie).flatMap(GraphQLServer.start)
      _ <- ZStream
             .serviceWithStream[MqttSubscriber](_.messages)
             .mapZIO(msg =>
               ZIO.serviceWithZIO[MessageProcessor](_.process(msg))
                 .tapError(e => ZIO.logError(s"Error processing ${msg.topic}: ${e.getMessage}"))
                 .orElse(ZIO.succeed(Nil))
             )
             .flatMap(ZStream.fromIterable)
             .mapZIO(event =>
               ZIO.serviceWithZIO[EventHandler](_.handle(event))
                 .tapError(e => ZIO.logError(s"Error handling event: ${e.getMessage}"))
                 .ignore
             )
             .runDrain
             .fork
      _ <- ZIO.logInfo("App running - press Ctrl+C to stop")
      _ <- ZIO.never
    yield ()

```


#### Short summary: 

empty definition using pc, found symbol in pc: 