FROM ubuntu:20.04
ARG ELK_VERSION
LABEL Name=elk_stack Version=${ELK_VERSION}
RUN apt-get -y update && apt-get install -y openjdk-11-jdk wget gnupg2 supervisor vim-tiny curl iputils-ping net-tools jq

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
RUN apt-get -y update && \
    adduser --system --disabled-password --disabled-login elkuser

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME    

RUN apt-get install -y elasticsearch=${ELK_VERSION}

RUN apt-get install -y kibana=${ELK_VERSION}

RUN apt-get install -y logstash=1:${ELK_VERSION}-1

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/

ADD scripts/start-elasticSearch.sh /usr/bin/start-elasticSearch.sh
ADD scripts/start-kibana.sh /usr/bin/start-kibana.sh

RUN chmod 777 /usr/bin/start-elasticSearch.sh
RUN chmod 777 /usr/bin/start-kibana.sh

#Custom settings connect-mqtt-source.properties
ADD scripts/.vimrc /root/.vimrc

#ENV ES_PATH_CONF=/path/to/my/config

# Supervisor config 
ADD supervisor/elasticSearch.conf supervisor/kibana.conf /etc/supervisor/conf.d/

EXPOSE 5601 9001 9200 9300

#ENTRYPOINT [ "/bin/bash" ]
CMD ["tail","-f","/dev/null"]
