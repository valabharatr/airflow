#!/usr/bin/env bash

CUR_SHELL=`ps -p $$ | awk '$1 != "PID" {print $(NF)}'`
if [ $CUR_SHELL = "bash" ]; then
    export PS1="\[\033[38;5;4m\][\[\033[0m\]\[\033[38;5;2m\]\t\[\033[0m\]\[\033[38;5;11m\] \[\033[0m\]\[\033[38;5;9m\]\h\[\033[0m\]\[\033[38;5;15m\] > \[\033[0m\]\[\033[38;5;11m\]\W\[\033[0m\]\[\033[38;5;4m\]]\[\033[0m\]\[\033[38;5;2m\]\\$\[\033[0m\]\[\033[38;5;15m\] \[\033[0m\]"
fi
export PROMPT_COMMAND='history -a'

# Kerberos settings
export KRB5_CONFIG=/app/hadoop_conf/current/krb5.conf

alias ll="ls -lh"

# Hadoop settings
export HADOOP_HOME=/usr/hdp/current/hadoop-client
export HADOOP_CONF_DIR=/app/hadoop_conf/current/hadoop
export YARN_CONF_DIR=/app/hadoop_conf/current/hadoop
export HADOOP_OPTS="-Djava.security.krb5.conf=/app/hadoop_conf/current/krb5.conf"

#Spark settings
#export SPARK_CONF_DIR=/etc/spark/conf/
export SPARK_HOME=/usr/local/spark
export SPARK_CONF_DIR=/usr/local/spark/conf

#Java Settings
#export JAVA_HOME=/usr/java/jdk1.8.0_131/
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/jre
export JRE_HOME=$JAVA_HOME
export PATH=/app/fgh/anaconda/bin:$JAVA_HOME/bin:$PATH

export PYSPARK_PYTHON=/opt/anaconda/bin/python
#export PYSPARK_DRIVER_PYTHON=/app/fgh/anaconda/bin/python
export PYSPARK_DRIVER_PYTHON=/opt/anaconda/bin/python


export HDP_VERSION=2.6.5.106-2

export KAFKA_OPTS="-Djava.security.auth.login.config=/app/fgh//kafka_client_jaas.conf -Djava.security.krb5.conf=/etc/krb5.conf"

export AIRFLOW_HOME=/app/fgh/airflow

export vault_token=s.igzPizVADA6Xes6oghXOYQTH


