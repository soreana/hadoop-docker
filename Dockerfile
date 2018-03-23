from ubuntu
LABEL maintainer="esterlinkof@gmail.com"

WORKDIR /home/

RUN apt-get update && \
    apt-get install --no-install-recommends -y wget ssh rsync software-properties-common python-software-properties debconf-utils net-tools curl nano default-jre default-jdk && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.1/hadoop-2.7.1.tar.gz && \
    mv ./hadoop-2.7.1.tar.gz /usr/local/hadoop.tar.gz && \
    cd /usr/local && \
    tar xzf hadoop.tar.gz && \
    mv hadoop-2.7.1 hadoop && \
    rm -rf hadoop-2.7.1.tar.gz && \
    rm -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    rm -f /etc/ssh/ssh_host_rsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    rm -f /root/.ssh/id_rsa | ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    service ssh start && \
    mkdir -p /root/.ssh/ && \
    ssh-keyscan localhost  >> ~/.ssh/known_hosts && \
    ssh-keyscan 0.0.0.0  >> ~/.ssh/known_hosts && \
    echo "\
# Some convenient aliases and functions for running Hadoop-related commands\n\
unalias fs &> /dev/null\n\
alias fs=\"hadoop fs\"\n\
unalias hls &> /dev/null\n\
alias hls=\"fs -ls\"\
" >> ~/.bashrc

# set up environment variables and conffig files
ARG RECONFIG=1
ENV HADOOP_HOME=/usr/local/hadoop \
    PATH="${PATH}:/usr/local/hadoop/bin"
COPY start.sh hadoop-env.sh mapred-site.xml yarn-site.xml yarn-site.multi-node.xml hdfs-site.xml hdfs-site.multi-node.xml core-site.xml core-site.multi-node.xml $HADOOP_HOME/etc/hadoop/

RUN mkdir -p /app/hadoop/tmp && \
    hdfs namenode -format && \
    chmod +x $HADOOP_HOME/etc/hadoop/start.sh

COPY WordCount.java mahdiz.big  HdfsReader.java HdfsWriter.java ./

ENTRYPOINT $HADOOP_HOME/etc/hadoop/start.sh && /bin/bash
