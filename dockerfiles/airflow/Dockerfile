FROM centos/python-36-centos7

USER root


ARG AIRFLOW_VERSION="1.10.6"
ARG KUBECTL_VERSION="1.11.0"
ARG AIRFLOW_HOME="/app/fgh/airflow"
ARG AIRFLOW_LOGS="$AIRFLOW_HOME/logs"
ARG AIRFLOW_PLUGIN="$AIRFLOW_HOME/plugins"


ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8


ENV SLUGIFY_USES_TEXT_UNIDECODE=yes \
    AIRFLOW_GPL_UNIDECODE=yes \
    AIRFLOW_HOME=$AIRFLOW_HOME \
    HOME=${AIRFLOW_HOME} \
    AIRFLOW_LOGS=$AIRFLOW_LOGS \
    AIRFLOW_PLUGIN=$AIRFLOW_PLUGIN \
    AIRFLOW_LOGS_SCHEDULER=$AIRFLOW_LOGS/scheduler \
    REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/jre 
ENV LD_LIBRARY_PATH=/opt/rh/rh-python36/root/usr/lib64

## proxy
#ENV NO_PROXY=192.168.99.100,127.0.0.1,localhost,10.240.210.130,172.30.1.1,172.17.0.1,172.18.0.1,ulvsecad04.devfg.example.com,example.com,nip.io
#ENV http_proxy=http://172.18.0.1:3128/
#ENV FTP_PROXY=http://172.18.0.1:3128/
#ENV ftp_proxy=http://172.18.0.1:3128/
#ENV HTTPS_PROXY=http://172.18.0.1:3128/
#ENV https_proxy=http://172.18.0.1:3128/
#ENV no_proxy=192.168.99.100,127.0.0.1,localhost,10.240.210.130,172.30.1.1,172.17.0.1,172.18.0.1,ulvsecad04.devfg.example.com,example.com,nip.io
#ENV HTTP_PROXY=http://172.18.0.1:3128/


## yum repos
#COPY files/yumrepos/bintray-sbt-rpm.repo /etc/yum.repos.d/
#COPY files/yumrepos/HDP.repo /etc/yum.repos.d/
#COPY files/yumrepos/epel-internal.repo /etc/yum.repos.d/

RUN yum -y install git wget java-1.8.0-openjdk vim freetds-devel krb5-server \
    openssl-devel libffi-devel freetds \
    postgresql postgresql-devel python-devel \
    curl rsync nmap \
    nmap-ncat


RUN mkdir -p $AIRFLOW_LOGS && \
    mkdir -p $AIRFLOW_LOGS_SCHEDULER && \
    mkdir -p $AIRFLOW_PLUGIN \
    mkdir -p $AIRFLOW_HOME/logs \
    mkdir -p $AIRFLOW_HOME/titan \
    midir -p /var/log/airflowlog

## copy example dags
COPY files/example_dags/ $AIRFLOW_HOME/dags/

COPY files/scripts/scheduler_health_check.py $AIRFLOW_HOME/scheduler_health_check.py

RUN chown -R 1001:0 $AIRFLOW_LOGS_SCHEDULER && \
    chown -R 1001:0 $AIRFLOW_HOME && \
    chown -R 1001:0 $AIRFLOW_LOGS && \
    chown -R 1001:0 /usr/lib/python2.7 && \
    chown -R 1001:0 /usr/lib64/python2.7 && \
    chmod 755 /usr/lib/python2.7 && \
    chmod 755 /usr/lib64/python2.7 && \
    chmod -R 777 $AIRFLOW_LOGS && \
    chmod -R 777 $AIRFLOW_HOME && \
    chmod -R 777 /var/log/airflowlog && \
    chmod -R 777 $AIRFLOW_LOGS_SCHEDULER && \
    chmod g=u /etc/passwd


## SSH keys
#RUN mkdir /root/.ssh
#COPY files/sshkeys/* /root/.ssh/
#RUN chmod 0700 /root/.ssh && chmod 600 /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa.pub
#RUN ssh-keyscan examplegithub.fg.example.com > /root/.ssh/known_hosts

ARG YUM_DEPENDENCIES="mariadb-devel openldap-devel mysql-devel mariadb python-devel python-setuptools python-pip gcc python-dateutil libffi-devel zlib-devel"
RUN yum install -y \
    @development \
    $YUM_DEPENDENCIES \
    && yum -y clean all && rm -rf /var/cache/yum

#RUN yum -y install hadoop-client hdp-select hive sqoop krb5-workstation \
#    libxml2-devel supervisor libs3 nginx octave libmpc-devel cairo cairo-devel cairomm-devel unixODBC unixODBC-devel

# RUN yum -y install spark2 spark2-master spark2-python spark2-worker

#RUN wget -e use_proxy=yes -e https_proxy=http://172.18.0.1:3128 -e http_proxy=http://172.18.0.1:3128 \
#https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz

#RUN tar xf spark-2.2.0-bin-hadoop2.7.tgz
#RUN mv spark-2.2.0-bin-hadoop2.7 /usr/local
#RUN rm -f spark-2.2.0-bin-hadoop2.7.tgz
## creates /usr/local/spark-2.2.0-bin-hadoop2.7

# Default args designed for deploying with the included Openshift template
ARG AIRFLOW_EXTRAS=async,celery,crypto,kubernetes,mysql,s3,statsd,postgres,hive,jdbc
ARG PIP_DEPENDENCIES="python-ldap mysqlclient"


RUN pip install 'marshmallow<2.20,>=2.18.0' 'kombu<4.7,>=4.6.7'

#RUN chgrp -R 0 /app
RUN pip install "apache-airflow[$AIRFLOW_EXTRAS]==$AIRFLOW_VERSION" $PIP_DEPENDENCIES

RUN pip install async celery crypto kubernetes mysql s3 statsd python-ldap mysqlclient flask_bcrypt \
    plotly scipy seaborn theano openpyxl tensorflow keras sklearn h5py jellyfish tldextract joypy python-Levenshtein \
    matplotlib yara-python pillow requests networkx

RUN pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install psycopg2-binary \
    && pip install psycopg2 \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install Flask-OAuthlib \
    && pip install 'redis>=2.10.5,<3'


#COPY files/example_airflow_ldap-1.2.0.tar.gz $AIRFLOW_HOME/example_airflow_ldap-1.2.0.tar.gz

# Install directly from EXAMPLE Nexus once the innersource python pipeline is setup
#RUN pip install --no-cache-dir $AIRFLOW_HOME/example_airflow_ldap-1.2.0.tar.gz


## setup symlinks
#RUN ln -sf /usr/hdp/current/hadoop-client/bin/* /usr/bin/
#RUN ln -sf /usr/hdp/current/hive-client/bin/* /usr/bin/


COPY files/scripts/uid_entrypoint.sh /uid_entrypoint.sh
COPY files/scripts/get_num_cores.sh /get_num_cores.sh
#COPY files/airflow.cfg $AIRFLOW_HOME/airflow.cfg

RUN chmod 755 /uid_entrypoint.sh && \
    chmod 755 /get_num_cores.sh

### create spark symlinks
#RUN ln -s /app/hadoop_conf/current/hadoop/hive-site.xml /usr/local/spark-2.2.0-bin-hadoop2.7/conf/hive-site.xml
#RUN ln -s /usr/local/spark-2.2.0-bin-hadoop2.7 /usr/local/spark
#RUN mkdir /etc/spark
#RUN ln -s /usr/local/spark-2.2.0-bin-hadoop2.7/conf /etc/spark/conf-2.2.0-bin-hadoop2.7
#
### copy spark config files spark-env.sh spark-defaults.conf log4j.properties
#COPY files/spark/* /etc/spark2/conf/
#COPY files/spark/* /usr/local/spark-2.2.0-bin-hadoop2.7/conf/
#
### clone titan 
#RUN ssh-agent bash -c 'ssh-add /root/.ssh/id_rsa; git clone git@examplegithub.fg.example.com:ran0/edlhp1-config.git'
#RUN mkdir -p /app/hadoop_conf/current/hadoop
#RUN cp -R edlhp1-config/guedev/* /app/hadoop_conf/current
#RUN mv edlhp1-config /root/titan_conf



### hadoop configs symlink
#RUN mv /etc/hadoop/conf /etc/hadoop/conf.`date +%Y-%m-%d.%H.%M.%S`
#RUN ln -s /app/hadoop_conf/current/hadoop /etc/hadoop/conf
#
## shims
#COPY files/shims/* /usr/bin/
#RUN cd /usr/bin && \
#    chmod +x beeline pyspark sparkR spark-shell spark-sql spark-submit
#
#
#
#RUN mkdir /etc/titan
#COPY files/titan/* /etc/titan/
#RUN chmod -R 755 /etc/titan
#
### copy topology script
#COPY files/titan/topology_script.py /app/hadoop_conf/current
#RUN chmod 755 /app/hadoop_conf/current/topology_script.py
#
#COPY files/titan/client_jaas.conf /app/fgh
COPY files/titan/edge.sh /app/.bashrc


RUN chown -R 1001 /app/fgh
RUN chmod -R 755 * /app/fgh
RUN chmod 644 /app/.bashrc && chown 1001 /app/.bashrc

### Anaconda
#RUN mkdir -p /opt/anaconda/bin/
#RUN ln -s /usr/bin/python /opt/anaconda/bin/
#RUN chmod -R a+rx /opt/anaconda/
#
### edge node files hdfs-site.xml hive-site.xml yarn-site.xml core-site.xml
#COPY files/edge/* /app/hadoop_conf/current/hadoop/
#RUN chmod 755 /app/hadoop_conf/current/hadoop/*
### copy krb5.conf to /etc
#RUN cp /app/hadoop_conf/current/krb5.conf /etc/krb5.conf
#
### jersey bundle jar
#COPY files/jersey-bundle-1.19.1.jar /usr/local/spark/jars/

### Copy keytab file
#COPY files/keytab/DFGHSRV01app@DEVFG.EXAMPLE.COM.keytab /app/fgh/
#
### Remove old and copy new yarn pkgs
#RUN rm -f /usr/local/spark/jars/hadoop-yarn*
#RUN cp -R /usr/hdp/current/hadoop-yarn-client/* /usr/local/spark/jars/
#RUN chmod 644 /usr/local/spark/jars/*
#RUN chown default /usr/local/spark/jars/*

## default python change due to hdfs errors
#RUN rm -f /opt/rh/rh-python36/root/usr/bin/python
#RUN ln -s /opt/anaconda/bin/python /opt/rh/rh-python36/root/usr/bin/python

## jce files
#COPY files/jce/* /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/jre/lib/security/
#
#
### get parsers
#RUN mkdir -p /app/fgh/module-jars/
#
#
### wtd parser
#RUN wget https://exampleartifactory.fg.example.com/artifactory/generic-fgh/data-converter/1.0.22/data-converter-1.0.22.zip
#RUN mkdir -p /app/fgh/airflow/dags && \
#    unzip data-converter-1.0.22.zip && \
#    mv data-converter-1.0.22 wtd-parser && \
#    chmod +x wtd-parser/bin/*.sh && \
#    cp -fp wtd-parser/dags/* /app/fgh/airflow/dags/ && \
#    rm -rf data-converter-1.0.22.zip
#
### pam alert
#RUN mkdir -p /app/fgh/module-jars/hint/conf
#RUN wget https://exampleartifactory.fg.example.com/artifactory/generic-fgh/pamalert/0.24/pamalert-0.24-bundle.zip
#RUN unzip pamalert-0.24-bundle.zip
#RUN mv pamalert-0.24 pam-alert && \
#    cp -r pam-alert/src/main/* pam-alert/ && \
#    rm -rf pam-alert/src/ && \
#    chmod -R +x pam-alert
### copy dags to airflow
#RUN cp -fp pam-alert/airflow/dags/* /app/fgh/airflow/dags/ 
#RUN cp -rfp pam-alert/conf/* /app/fgh/module-jars/hint/conf
#RUN mkdir -p /app/fgh/airflow/apps/pamalert_reporting
#RUN cp -fp pam-alert/airflow/apps/pamalert_reporting/* /app/fgh/airflow/apps/pamalert_reporting
#RUN rm -rf pamalert-0.24-bundle.zip
#
### nightvision parsers
#COPY files/parsers/nightvisionarch.tar.gz .
#RUN tar xf nightvisionarch.tar.gz
#RUN cp -Rp nightvisionarch/* /app/fgh/module-jars/
#RUN rm -rf nightvisionarch.tar.gz nightvisionarch/
#RUN chmod -R 755 /app/fgh/module-jars/*


## virtual envs
#RUN mkdir -p /app/fgh/virtual_env/flightrisk && \
#    chmod 755 /app/fgh/virtual_env/flightrisk
#
#COPY files/virtualenv/flightrisk_pip_req.txt /app/fgh/virtual_env/flightrisk/
#
#RUN virtualenv --python=/usr/bin/python2 /app/fgh/virtual_env/flightrisk
#RUN source /app/fgh/virtual_env/flightrisk/bin/activate
#RUN /app/fgh/virtual_env/flightrisk/bin/pip install --upgrade pip
#RUN /app/fgh/virtual_env/flightrisk/bin/pip install setuptools --upgrade
#RUN /app/fgh/virtual_env/flightrisk/bin/pip install utils
#RUN /app/fgh/virtual_env/flightrisk/bin/pip install -r /app/fgh/virtual_env/flightrisk/flightrisk_pip_req.txt
#RUN /app/fgh/virtual_env/flightrisk/bin/pip install PyArrow keras

RUN pip install psycopg2 paramiko


RUN chgrp -R 0 $AIRFLOW_HOME && chmod -R 777 $AIRFLOW_HOME
#RUN chgrp -R 0 /etc/titan && chmod -R 777 /etc/titan
#RUN chgrp -R 0 /var/log/airflow && chmod -R 777 /var/log/airflow

RUN chown -R 1001:0 /app
#RUN chown -R 1001:0 /etc/titan
#RUN chown -R 1001:0 /root/titan_conf
#RUN chown -R 1001:0 /var/log/airflow
RUN chmod -R 775 /app 
#    chmod -R 775 /etc/titan && \
#    chmod -R 775 /root/titan_conf && \
#    chmod -R 775 /var/log/airflow

#RUN mkdir /usr/local/airflow
#RUN chgrp -R 0 /usr/local/airflow && chmod -R 777 /usr/local/airflow

RUN yum -y clean all && rm -rf /var/cache/yum

RUN curl -L -o /usr/local/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
        chmod +x /usr/local/bin/kubectl


USER 1001

ENTRYPOINT ["/uid_entrypoint.sh"]
EXPOSE 8080
CMD ["webserver"]
