export DATADOG_APP_KEY=
export DATADOG_API_KEY=
export SNYK_TOKEN=
export MAVEN_OPTS="-javaagent:dd-java-agent.jar -Ddd.profiling.enabled=true -XX:FlightRecorderOptions=stackdepth=256 -Ddd.service=javagoof -Ddd.env=lab -Ddd.version=.01"
export PATH=:$PATH:/home/ec2-user/java-goof/apache-maven-3.8.1/bin/
