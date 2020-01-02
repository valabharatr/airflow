FROM centos/python-36-centos7

USER root

ARG AIRFLOW_VERSION="1.10.6"
ARG KUBECTL_VERSION="1.11.0"
ARG AIRFLOW_HOME="/app/fgh/airflow"
ARG AIRFLOW_LOGS="$AIRFLOW_HOME/logs"
ARG AIRFLOW_PLUGIN="$AIRFLOW_HOME/plugins"
ARG YUM_DEPENDENCIES=""

# Default args designed for deploying with the included Openshift template
ARG AIRFLOW_EXTRAS=""
ARG PIP_DEPENDENCIES=""

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

RUN mkdir -p $AIRFLOW_LOGS && \
    mkdir -p $AIRFLOW_LOGS_SCHEDULER && \
    mkdir -p $AIRFLOW_PLUGIN && \
    mkdir -p $AIRFLOW_HOME/logs && \
    mkdir -p $AIRFLOW_HOME/titan && \
    mkdir -p /var/log/airflowlog && \
    yum -y install mariadb-devel mysql-devel mariadb python-devel python-setuptools python-pip gcc python-dateutil \
           libffi-devel zlib-devel gcc-c++ freetds-devel openssl-devel freetds curl rsync nmap nmap-ncat && \
    if [ -n "${YUM_DEPENDENCIES}" ]; then yum -y install ${YUM_DEPENDENCIES}; fi && \
    yum -y clean all && rm -rf /var/cache/yum && \
    pip install -U pip && \
    pip install "apache-airflow[async,celery,crypto,kubernetes,mysql,statsd,jdbc]==$AIRFLOW_VERSION" \
                mysqlclient virtualenv && \
    if [ -n "${PIP_DEPENDENCIES}" ]; then pip install ${PIP_DEPENDENCIES}; fi && \
    if [ -n "${AIRFLOW_EXTRAS}" ]; then pip install "${AIRFLOW_EXTRAS}==${AIRFLOW_VERSION}"; fi && \
    pip install 'redis>=2.10.5,<3' && \
    chown -R 1001:0 $AIRFLOW_HOME && \
    curl -L -o /usr/local/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl


## copy example dags
COPY files/example_dags/ $AIRFLOW_HOME/dags/
COPY files/scripts/scheduler_health_check.py $AIRFLOW_HOME/scheduler_health_check.py
COPY files/scripts/uid_entrypoint.sh /uid_entrypoint.sh
COPY files/scripts/get_num_cores.sh /get_num_cores.sh

RUN chown -R 1001:0 /usr/lib/python2.7 && \
    chown -R 1001:0 /usr/lib64/python2.7 && \
    chown -R 1001:0 $AIRFLOW_HOME && \
    chmod 755 /usr/lib/python2.7 && \
    chmod 755 /usr/lib64/python2.7 && \
    chmod -R 777 $AIRFLOW_LOGS && \
    chmod -R 777 $AIRFLOW_HOME && \
    chmod -R 777 /var/log/airflowlog && \
    chmod -R 777 $AIRFLOW_LOGS_SCHEDULER && \
    chmod g=u /etc/passwd

## Change User to default
USER 1001

ENTRYPOINT ["/uid_entrypoint.sh"]
EXPOSE 8080
CMD ["webserver"]
