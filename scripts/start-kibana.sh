#!/bin/bash

# Optional ENV variables:
# * CONNECT_PLUGIN_PATH: Set to a list of filesystem paths separated by commas (,) to enable class loading isolation for plugins
# 						(connectors, converters, transformations). The list should consist of top level directories that include
# 						any combination of:
# 						a) directories immediately containing jars with plugins and their dependencies
# 						b) uber-jars with plugins and their dependencies
# 						c) directories immediately containing the package directory structure of classes of plugins and their dependencies
# 						Note: symlinks will be followed to discover dependencies or plugins.
# 						Examples:
# 						plugin.path=/usr/local/share/java,/usr/local/share/kafka/plugins,/opt/connectors,

# Standalone config file
#CONFIG_FILE=$KAFKA_HOME/config/connect-standalone.properties

# Distributed config file
CONFIG_FILE=$KAFKA_HOME/config/connect-distributed.properties

# comment target
comment() {
  sed -r -i "s/^$1/#$1/g" $CONFIG_FILE
}

# Uncomment target
uncomment() {
  echo $1
  sed -r -i "s/^#$1/$1/g" $CONFIG_FILE
}


# Set the external host and port
if [ ! -z "$CONNECT_PLUGIN_PATH" ]; then
    PLUGIN_PATH="$KAFKA_HOME/libs"
    #PLUGIN_PATH="$KAFKA_HOME/libs,$CONNECT_PLUGIN_PATH"
    echo "connect plugin path : $PLUGIN_PATH"
    uncomment plugin.path
    if grep -q "^plugin.path" $CONFIG_FILE; then
        sed -r -i "s|(plugin.path)=(.*)|\1=$PLUGIN_PATH|g" $CONFIG_FILE
    else
	    echo -e '\n' >> $CONFIG_FILE
        echo "plugin.path=$PLUGIN_PATH" >> $CONFIG_FILE
    fi
fi

if [ ! -z "$CONNECT_REST_PORT" ]; then
    echo "connect rest port: $CONNECT_REST_PORT"
    uncomment rest.port
    if grep -q "^rest.port" $CONFIG_FILE; then
        sed -r -i "s/(rest.port)=(.*)/\1=$CONNECT_REST_PORT/g" $CONFIG_FILE
    else
        echo -e '\n' >> $CONFIG_FILE
        echo "rest.port=$CONNECT_REST_PORT" >> $CONFIG_FILE
    fi
fi


if [ ! -z "$CONNECT_KEY_SCHEMA" ]; then
    echo "key.converter.schemas.enable: $CONNECT_KEY_SCHEMA"
    uncomment key.converter.schemas.enable
    if grep -q "^key.converter.schemas.enable" $CONFIG_FILE; then
        sed -r -i "s/(key.converter.schemas.enable)=(.*)/\1=$CONNECT_KEY_SCHEMA/g" $CONFIG_FILE
    else
        echo -e '\n' >> $CONFIG_FILE
        echo "key.converter.schemas.enable=$CONNECT_KEY_SCHEMA" >> $CONFIG_FILE
    fi
fi

if [ ! -z "$CONNECT_VALUE_SCHEMA" ]; then
    echo "value.converter.schemas.enable: $CONNECT_VALUE_SCHEMA"
    uncomment value.converter.schemas.enable
    if grep -q "^value.converter.schemas.enable" $CONFIG_FILE; then
        sed -r -i "s/(value.converter.schemas.enable)=(.*)/\1=$CONNECT_VALUE_SCHEMA/g" $CONFIG_FILE
    else
        echo -e '\n' >> $CONFIG_FILE
        echo "value.converter.schemas.enable=$CONNECT_VALUE_SCHEMA" >> $CONFIG_FILE
    fi
fi


# No such command at of now
# wait for Kafka to start up
#until /usr/share/zookeeper/bin/zkServer.sh status; do
# sleep 0.1
#done


tail -f $LOG_DIR/server.log | while read LOGLINE
do
 echo ${LOGLINE}
 [[ "${LOGLINE}" == *'started'* ]] && pkill -P $$ tail
 echo "Kafka server has started"
done

# Download JDBC Jar
#cd /usr/share/java/kafka-connect-jdbc/
#curl https://cdn.mysql.com/Downloads/Connector-J/mysql-connector-java-8.0.16.tar.gz | tar xz
# Using Ivy Standalone jar
cd ~
curl -L -O http://search.maven.org/remotecontent?filepath=org/apache/ivy/ivy/2.3.0/ivy-2.3.0.jar

# Maven description : dependency org="mysql" name="mysql-connector-java" rev="8.0.11"	

#java -jar ivy-2.3.0.jar -dependency mysql mysql-connector-java 8.0.11 -retrieve "$CONNECT_PLUGIN_PATH/[artifact]-[revision](-[classifier]).[ext]"



#Temporary Fix :
ln -s $CONNECT_PLUGIN_PATH $KAFKA_HOME/libs/kafka-connect-common 

echo "Starting Kafka Connect"
# Run Kafka connect in standalone mode
#$KAFKA_HOME/bin/connect-standalone.sh $CONFIG_FILE $KAFKA_HOME/config/connect-mqtt-source.properties

#Run Kafka connect in distributed mode
$KAFKA_HOME/bin/connect-distributed.sh $CONFIG_FILE

