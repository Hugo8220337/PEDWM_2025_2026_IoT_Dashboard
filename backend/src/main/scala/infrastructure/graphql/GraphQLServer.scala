package infrastructure.graphql

import caliban.{GraphQLInterpreter, ZHttpAdapter}
import zio.*
import zio.http.*
import zio.http.Header.{AccessControlAllowOrigin, AccessControlAllowMethods, AccessControlAllowHeaders, AccessControlAllowCredentials}
import zio.http.Middleware.CorsConfig

object GraphQLServer:

  private val corsConfig = CorsConfig(
    allowedOrigin = _ => Some(AccessControlAllowOrigin.All),
    allowedMethods = AccessControlAllowMethods(
      Method.GET, Method.POST, Method.OPTIONS, Method.PUT, Method.DELETE
    ),
    allowedHeaders = AccessControlAllowHeaders.All,
    allowCredentials = AccessControlAllowCredentials.Allow
  )

  def start(interpreter: GraphQLInterpreter[Any, ?]): UIO[Unit] =
    val routes =
      Routes(
        Method.POST / "graphql"         -> ZHttpAdapter.makeHttpService(interpreter),
        Method.GET  / "graphql" / "ws"  -> ZHttpAdapter.makeWebSocketService(interpreter)
      ) @@ Middleware.cors(corsConfig)
    Server.serve(routes)
      .provide(Server.defaultWithPort(8088))
      .orDie
      .fork
      .unit *> ZIO.logInfo("GraphQL server listening on http://localhost:8088/graphql")
