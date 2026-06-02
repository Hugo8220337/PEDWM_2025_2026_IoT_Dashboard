package infrastructure.database

import doobie.Transactor
import doobie.hikari.HikariTransactor
import doobie.util.ExecutionContexts
import infrastructure.config.DatabaseConfig
import org.flywaydb.core.Flyway
import zio.*
import zio.interop.catz.*

object Database:

  val transactorLayer: ZLayer[DatabaseConfig, Throwable, Transactor[Task]] =
    ZLayer.scoped {
      ZIO.serviceWithZIO[DatabaseConfig] { config =>
        for
          _  <- ensureDatabase(config)
          _  <- ZIO.attempt {
                  Flyway.configure()
                    .dataSource(config.url, config.user, config.password)
                    .locations("classpath:db/migration")
                    .load()
                    .migrate()
                }.unit
          xa <- (for
                  ec <- ExecutionContexts.fixedThreadPool[Task](config.maxPoolSize)
                  xa <- HikariTransactor.newHikariTransactor[Task](
                          "org.postgresql.Driver",
                          config.url,
                          config.user,
                          config.password,
                          ec
                        )
                yield xa: Transactor[Task]).toScopedZIO
        yield xa
      }
    }

  private def ensureDatabase(config: DatabaseConfig): Task[Unit] =
    ZIO.attempt {
      val dbName  = config.url.split("/").last.split("\\?").head
      val rootUrl = config.url.substring(0, config.url.lastIndexOf('/')) + "/postgres"
      val conn    = java.sql.DriverManager.getConnection(rootUrl, config.user, config.password)
      try
        val exists = conn.createStatement()
          .executeQuery(s"SELECT 1 FROM pg_database WHERE datname = '$dbName'")
          .next()
        if !exists then conn.createStatement().execute(s"""CREATE DATABASE "$dbName"""")
      finally
        conn.close()
    }
