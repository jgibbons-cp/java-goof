export DATADOG_APP_KEY=
export DATADOG_API_KEY=
export SNYK_TOKEN=
export MAVEN_OPTS="-javaagent:dd-java-agent.jar -Ddd.profiling.enabled=true -XX:FlightRecorderOptions=stackdepth=256 -Ddd.service=javagoof -Ddd.env=lab -Ddd.version=.01"
