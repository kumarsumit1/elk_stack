#!/bin/bash

# Optional ENV variables:
# * ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic
#https://www.confluent.io/blog/kafka-listeners-explained

# your target file
CONFIG_FILE=$KAFKA_HOME/config/server.properties

HOST_IP=$(grep $HOSTNAME /etc/hosts | awk '{print $1}')

# syntax of sed: s/regexp/replacement/flags FileName
# g - mentioning repeated search of the pattern until end of file is reached.
#If you have a slash / in the variable then use different separator
#https://askubuntu.com/questions/76808/how-do-i-use-variables-in-a-sed-command

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
if [ ! -z "$KAFKA_LISTENERS" ]; then
    echo "listner: $KAFKA_LISTENERS"
    uncomment listeners
    if grep -q "^listeners" $CONFIG_FILE; then
        sed -r -i "s|^(listeners)=(.*)|\1=$KAFKA_LISTENERS|g" $CONFIG_FILE
    else
	    echo -e '\n' >> $CONFIG_FILE
        echo "listeners = $KAFKA_LISTENERS" >> $CONFIG_FILE
    fi
fi

if [ ! -z "$KAFKA_ADVERTISED_LISTENERS" ]; then
    ADVERTISED_LISTENERS=$(echo $KAFKA_ADVERTISED_LISTENERS | sed -r "s/HOSTNAME/$HOST_IP/")
    echo "advertised listeners: $ADVERTISED_LISTENERS"
    uncomment advertised.listeners
    if grep -q "^advertised.listeners" $CONFIG_FILE; then
        sed -r -i "s|^(advertised.listeners)=(.*)|\1=$ADVERTISED_LISTENERS|g" $CONFIG_FILE
    else
        echo -e '\n' >> $CONFIG_FILE
        echo "advertised.listeners=$ADVERTISED_LISTENERS" >> $CONFIG_FILE
    fi
fi

# Map between listener names and security protocols.
if [ ! -z "$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP" ]; then
    ADVERTISED_LISTENERS=$(echo $KAFKA_LISTENER_SECURITY_PROTOCOL_MAP | sed -r "s/HOSTNAME/$HOST_IP/")
    echo "listener.security.protocol.map: $KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
    uncomment listener.security.protocol.map
    if grep -q "^listener.security.protocol.map" $CONFIG_FILE; then
        sed -r -i "s|^(listener.security.protocol.map)=(.*)|\1=$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP|g" $CONFIG_FILE
    else
        echo -e '\n' >> $CONFIG_FILE
        echo "listener.security.protocol.map=$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP" >> $CONFIG_FILE
    fi
fi



# Name of listener used for communication between brokers.
if [ ! -z "$KAFKA_INTER_BROKER_LISTENER_NAME" ]; then
    echo "inter.broker.listener.name: $KAFKA_INTER_BROKER_LISTENER_NAME"
    echo -e '\n' >> $CONFIG_FILE
    echo "inter.broker.listener.name=$KAFKA_INTER_BROKER_LISTENER_NAME" >> $CONFIG_FILE
fi

# stores the logs under /var/log/kafka-logs/<topic.name>-<topic.partition>
echo "log.dir: /var/log/kafka-logs"
echo -e '\n' >> $CONFIG_FILE
echo "log.dir=/var/log/kafka-logs" >> $CONFIG_FILE
echo "log.dirs=/var/log/kafka-logs" >> $CONFIG_FILE
# Kafka Application Log Configuration
#export LOG_DIR=/var/log/kafka
echo 'Kafka application logs set to ' $LOG_DIR

# Set the zookeeper chroot
if [ ! -z "$ZK_CHROOT" ]; then
    # wait for zookeeper to start up
    until /usr/share/zookeeper/bin/zkServer.sh status; do
      sleep 0.1
    done

    # create the chroot node
    echo "create /$ZK_CHROOT \"\"" | /usr/share/zookeeper/bin/zkCli.sh || {
        echo "can't create chroot in zookeeper, exit"
        exit 1
    }

    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=localhost:2181\/$ZK_CHROOT/g" $CONFIG_FILE
fi

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $CONFIG_FILE
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $CONFIG_FILE
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $CONFIG_FILE
fi

# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $CONFIG_FILE
fi

# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $CONFIG_FILE