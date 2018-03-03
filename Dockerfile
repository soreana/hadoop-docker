from ubuntu
LABEL maintainer="esterlinkof@gmail.com"

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /home/
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.1/hadoop-2.7.1.tar.gz

RUN apt-get update && \
    apt-get install -y software-properties-common python-software-properties debconf-utils && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    java -version

RUN apt-get update && \
    apt-get install --no-install-recommends  -y ssh rsync &&  \
    rm -rf /var/lib/apt/lists/*


RUN cp ./hadoop-2.7.1.tar.gz /usr/local/hadoop.tar.gz && \
    cd /usr/local && \
    tar xzf hadoop.tar.gz && \
    mv hadoop-2.7.1 hadoop
    
    
# set up environment variables and conffig files
ARG RECONFIG=1
ENV HADOOP_HOME /usr/local/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV HADOOP_CLASSPATH=/usr/lib/jvm/java-8-oracle/lib/tools.jar
RUN echo "# Some convenient aliases and functions for running Hadoop-related commands\nunalias fs &> /dev/null\nalias fs=\"hadoop fs\"\nunalias hls &> /dev/null\nalias hls=\"fs -ls\"" >> ~/.bashrc
ENV PATH="${PATH}:$HADOOP_HOME/bin"
COPY start.sh yarn-site.xml hadoop-env.sh hdfs-site.xml mapred-site.xml core-site.xml $HADOOP_HOME/etc/hadoop/
ADD WordCount.java mahdiz.big ./

RUN rm -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    rm -f /etc/ssh/ssh_host_rsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    rm -f /root/.ssh/id_rsa | ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys 

RUN mkdir -p /app/hadoop/tmp && \
    mkdir -p /root/.ssh/ && \
    service ssh start && \
    ssh-keyscan localhost  >> ~/.ssh/known_hosts && \
    ssh-keyscan 0.0.0.0  >> ~/.ssh/known_hosts && \
    hdfs namenode -format && \
    chmod +x $HADOOP_HOME/etc/hadoop/start.sh

ENTRYPOINT $HADOOP_HOME/etc/hadoop/start.sh && /bin/bash
