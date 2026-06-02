val scala3Version     = "3.8.3"
val catsEffectVersion = "3.5.7"
val doobieVersion     = "1.0.0-RC4"
val zioVersion        = "2.1.14"
val calibanVersion    = "2.9.0"
val zioHttpVersion    = "3.0.0"

lazy val root = project
  .in(file("."))
  .settings(
    name := "backend",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    Compile / PB.targets := Seq(
      scalapb.gen() -> (Compile / sourceManaged).value / "scalapb"
    ),

    libraryDependencies ++= Seq(
      "org.typelevel"       %% "cats-effect"      % catsEffectVersion,
      "org.tpolecat"        %% "doobie-core"      % doobieVersion,
      "org.tpolecat"        %% "doobie-hikari"    % doobieVersion,
      "org.tpolecat"        %% "doobie-postgres"  % doobieVersion,
      "org.postgresql"       % "postgresql"       % "42.7.3",
      "org.flywaydb"         % "flyway-core"      % "9.22.3",
      "dev.zio"             %% "zio"              % zioVersion,
      "dev.zio"             %% "zio-streams"      % zioVersion,
      "dev.zio"             %% "zio-interop-cats" % "23.1.0.3",
      "com.thesamet.scalapb" %% "scalapb-runtime" % scalapb.compiler.Version.scalapbVersion % "protobuf",
      "org.eclipse.paho"     % "org.eclipse.paho.client.mqttv3" % "1.2.5",
      "com.github.ghostdogpr" %% "caliban"          % calibanVersion,
      "com.github.ghostdogpr" %% "caliban-zio-http" % calibanVersion,
      "dev.zio"               %% "zio-http"         % zioHttpVersion,
      "org.scalameta"         %% "munit"            % "1.3.0" % Test
    ),

    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", "services", _*) => MergeStrategy.concat
      case PathList("META-INF", _*)             => MergeStrategy.discard
      case "reference.conf"                     => MergeStrategy.concat
      case "module-info.class"                  => MergeStrategy.discard
      case _                                    => MergeStrategy.first
    }
  )
