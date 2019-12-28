FROM centos/python-36-centos7

USER root

ARG AIRFLOW_VERSION="1.10.6"
ARG KUBECTL_VERSION="1.11.0"
ARG AIRFLOW_HOME="/app/fgh/airflow"
ARG AIRFLOW_LOGS="$AIRFLOW_HOME/logs"
ARG AIRFLOW_PLUGIN="$AIRFLOW_HOME/plugins"
ARG YUM_DEPENDENCIES="mariadb-devel openldap-devel mysql-devel mariadb python-devel python-setuptools python-pip gcc python-dateutil libffi-devel zlib-devel"

# Default args designed for deploying with the included Openshift template
ARG AIRFLOW_EXTRAS=async,celery,crypto,kubernetes,mysql,s3,statsd,hive,jdbc
ARG PIP_DEPENDENCIES="python-ldap mysqlclient"

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
#ENV http_proxy=http://172.18.0.1:3128/
#ENV ftp_proxy=http://172.18.0.1:3128/
#ENV https_proxy=http://172.18.0.1:3128/
#ENV no_proxy=192.168.99.100,127.0.0.1,localhost,10.240.210.130,172.30.1.1,172.17.0.1,172.18.0.1,ulvsecad04.devfg.example.com,example.com,nip.io


RUN mkdir -p $AIRFLOW_LOGS && \
    mkdir -p $AIRFLOW_LOGS_SCHEDULER && \
    mkdir -p $AIRFLOW_PLUGIN && \
    mkdir -p $AIRFLOW_HOME/logs && \
    mkdir -p $AIRFLOW_HOME/titan && \
    mkdir -p /var/log/airflowlog && \
    chown -R 1001:0 /usr/lib/python2.7 && \
    chown -R 1001:0 /usr/lib64/python2.7 && \
    chmod 755 /usr/lib/python2.7 && \
    chmod 755 /usr/lib64/python2.7 && \
    chmod -R 777 $AIRFLOW_LOGS && \
    chmod -R 777 $AIRFLOW_HOME && \
    chmod -R 777 /var/log/airflowlog && \
    chmod -R 777 $AIRFLOW_LOGS_SCHEDULER && \
    chmod g=u /etc/passwd && \
    yum -y install git wget java-1.8.0-openjdk vim freetds-devel krb5-server \
           openssl-devel libffi-devel freetds python-devel curl rsync nmap nmap-ncat && \
    yum install -y @development $YUM_DEPENDENCIES && \
    yum -y clean all && rm -rf /var/cache/yum && \
    pip install -U pip && \
    pip install "marshmallow<2.20,>=2.18.0" "kombu<4.7,>=4.6.7" "apache-airflow[$AIRFLOW_EXTRAS]==$AIRFLOW_VERSION" \
                $PIP_DEPENDENCIES async celery crypto kubernetes mysql s3 statsd python-ldap mysqlclient flask_bcrypt \
                plotly scipy seaborn theano openpyxl tensorflow keras sklearn h5py jellyfish tldextract joypy \
                python-Levenshtein matplotlib yara-python pillow requests networkx  setuptools wheel pytz \
                psycopg2-binary psycopg2 pyOpenSSL ndg-httpsclient pyasn1 Flask-OAuthlib paramiko && \
    pip install 'redis>=2.10.5,<3' && \
    chown -R 1001:0 $AIRFLOW_HOME
    

## copy example dags
COPY files/example_dags/ $AIRFLOW_HOME/dags/
COPY files/scripts/scheduler_health_check.py $AIRFLOW_HOME/scheduler_health_check.py
COPY files/scripts/uid_entrypoint.sh /uid_entrypoint.sh
COPY files/scripts/get_num_cores.sh /get_num_cores.sh

RUN curl -L -o /usr/local/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
        chmod +x /usr/local/bin/kubectl

USER 1001

ENTRYPOINT ["/uid_entrypoint.sh"]
EXPOSE 8080
CMD ["webserver"]
