FROM openjdk:8-jre-alpine

WORKDIR /app

ENV serverIP 127.0.0.1
ENV appName SpringV2

ENV dbdomain cluster
ENV dbuser testuser
ENV dbpw test1234
ENV bucketname tests3

RUN set -eux; \
        apk add python3 ; \
        pip3 --no-cache-dir install -U awscli

RUN mkdir pinpoint
ADD pinpoint-agent-2.3.3.tar.gz ./pinpoint

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
COPY application.properties application.properties

EXPOSE 8080

ENTRYPOINT sed -i 's|dbdomain|'"$dbdomain"'|g' ./application.properties \ 
    && sed -i 's|dbpw|'"$dbpw"'|g' ./application.properties \
    && sed -i 's|dbuser|'"$dbuser"'|g' ./application.properties \
    && sed -i 's|bucketname|'"$bucketname"'|g' ./application.properties \
    && sed -i 's|'"127.0.0.1"'|'"$serverIP"'|g' ./pinpoint/pinpoint-agent-2.3.3/pinpoint-root.config \
    && sed -i 's|'"127.0.0.1"'|'"$serverIP"'|g' ./pinpoint/pinpoint-agent-2.3.3/profiles/local/pinpoint.config \
    && sed -i 's|'"127.0.0.1"'|'"$serverIP"'|g' ./pinpoint/pinpoint-agent-2.3.3/profiles/release/pinpoint.config \
    && java -jar -javaagent:./pinpoint/pinpoint-agent-2.3.3/pinpoint-bootstrap-2.3.3.jar -Dpinpoint.applicationName=${appName} -Dpinpoint.agentId=`hostname -i` app.jar
