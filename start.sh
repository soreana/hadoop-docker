#!/bin/bash

# set cluster's hosts IP
HADOOP_HOSTS="${HADOOP_HOSTS:-127.0.0.1 master}"
echo -e "\n#Hadoop hosts" >> /etc/hosts
echo "$HADOOP_HOSTS" | sed -e $'s/,/\\\n/g' >> /etc/hosts

echo "$HADOOP_HOSTS" | \
    sed -e $'s/,/\\\n/g' | \
    awk '{print $2}' > $HADOOP_HOME/etc/hadoop/slaves

# set my role
MY_ROLE="${MY_ROLE:-slave}"

# calculate host numbers
HOST_NUMBERS=`echo ${HADOOP_HOSTS} | tr -cd , | wc -c`
let "HOST_NUMBERS=HOST_NUMBERS+1"

if [ ${HOST_NUMBERS} -gt 1 ]
then
    # multi node initialization
    IS_SINGLE=false
else
    # single node initialization
    MY_ROLE="master-slave"
    IS_SINGLE=true
fi

echo ${HOST_NUMBERS}
echo ${IS_SINGLE}
echo ${MY_ROLE}

service ssh start

if [ "${IS_SINGLE}" == false ]; then
    echo "$HADOOP_HOSTS" | \
        sed -e $'s/,/\\\n/g' | \
        awk '{print $2}' | \
        while read line ; do ssh-keyscan ${line} >> ~/.ssh/known_hosts ; done
    mv $HADOOP_HOME/etc/hadoop/yarn-site.multi-node.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml 
    mv $HADOOP_HOME/etc/hadoop/core-site.multi-node.xml $HADOOP_HOME/etc/hadoop/core-site.xml 
    mv $HADOOP_HOME/etc/hadoop/hdfs-site.multi-node.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml 

    if [ "${MY_ROLE}" == "master" ]; then
    	$HADOOP_HOME/sbin/start-dfs.sh && \
            $HADOOP_HOME/sbin/start-yarn.sh && \
            hdfs dfs -mkdir -p /user/sina/data && \
            hdfs dfs -copyFromLocal /home/mahdiz.big /user/sina/data
    fi
fi

if [ "${IS_SINGLE}" == true ]; then
    ssh-keyscan master  >> ~/.ssh/known_hosts

    $HADOOP_HOME/sbin/start-dfs.sh && \
        $HADOOP_HOME/sbin/start-yarn.sh && \
        hdfs dfs -mkdir -p /user/sina/data && \
        hdfs dfs -copyFromLocal /home/mahdiz.big /user/sina/data
fi
