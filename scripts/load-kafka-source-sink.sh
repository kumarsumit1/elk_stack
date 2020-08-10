#!/bin/bash

# Wait until Kafka connector is started and listens on port 8083.
while [ -z "`netstat -tln | grep 8083`" ]; do
  echo 'Waiting for Kafka connector to start ⏳⏳⏳'
  sleep 1
done
echo 'Kafka connector is up and running'

echo "Waiting for Kafka Plugins to load (checking localhost:8083/connector-plugins) "
HTTPD=`curl -s localhost:8083/connector-plugins | jq -c ' .[] | select( .class | contains("MqttSourceConnecto","JdbcSinkConnector")) | .class ' | wc -l`
until [ "$HTTPD" == "2" ]; do
    sleep 3
    echo "Sleeping for 3 secs"
    HTTPD=`curl -s localhost:8083/connector-plugins | jq -c ' .[] | select( .class | contains("MqttSourceConnecto","JdbcSinkConnector")) | .class ' | wc -l`
done

echo "Starting MQTT Source connector"
curl -d @$KAFKA_HOME/config/connect-mqtt-source.json -H "Content-Type: application/json" -X POST http://localhost:8083/connectors 

echo "Starting JDBC Sink connector"
curl -d @$KAFKA_HOME/config/connect-jdbc-sink.json -H "Content-Type: application/json" -X POST http://localhost:8083/connectors 

echo "----------Status of Connectors---------------"
curl -s "http://localhost:8083/connectors"| \
  jq '.[]'| \
  xargs -I{connector_name} curl -s "http://localhost:8083/connectors/"{connector_name}"/status"| \
  jq -c -M '[.name,.connector.state,.tasks[].state]|join(":|:")'| \
  sed 's/\"//g'| sort