FROM centos/python-36-centos7:latest

ENV TERM linux
ENV LD_LIBRARY_PATH=/opt/rh/rh-python36/root/usr/lib64

ARG AIRFLOW_VERSION
ARG AIRFLOW_HOME
ARG AIRFLOW_DEPS
ARG PYTHON_DEPS
ARG KUBECTL_VERSION

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

USER root

ENV AIRFLOW_GPL_UNIDECODE yes
ENV SLUGIFY_USES_TEXT_UNIDECODE=yes
ENV REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/jre 
ENV HOME ${AIRFLOW_HOME}
ENV AIRFLOW_HOME ${AIRFLOW_HOME}

RUN yum -y install epel-release
RUN yum -y install git wget java-1.8.0-openjdk vim

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
    ' \
    && yum update -yqq \
    && yum upgrade -yqq \
    && yum install -yqq  \
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
        libpq5 \
        git \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install psycopg2-binary \
    && pip install psycopg2 \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[async,kubernetes,s3,statsd,crypto,celery,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip install 'redis>=2.10.5,<3' \
    && pip install futures async celery crypto kubernetes mysql s3 statsd python-ldap mysqlclient flask_bcrypt plotly scipy seaborn theano openpyxl tensorflow keras sklearn h5py jellyfish tldextract joypy python-Levenshtein matplotlib yara-python pillow requests networkx \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && yum remove -y $buildDeps \
    && yum clean all

RUN yum install -y \
    @development \
    mariadb-devel openldap-devel mysql-devel mariadb python-devel python-dateutil gcc libffi-devel zlib-devel openssl-devel \
    && yum -y clean all \
    && rm -rf /var/cache/yum

RUN mkdir -p ${AIRFLOW_HOME}

COPY scheduler_health_check.py $AIRFLOW_HOME/scheduler_health_check.py

RUN chown -R 1001:0 $AIRFLOW_HOME && \
    chown -R 1001:0 /usr/lib/python2.7 && \
    chown -R 1001:0 /usr/lib64/python2.7 && \
    chmod 755 /usr/lib/python2.7 && \
    chmod 755 /usr/lib64/python2.7 && \
    chmod -R 777 $AIRFLOW_HOME && \
    chmod g=u /etc/passwd

COPY uid_entrypoint.sh /uid_entrypoint.sh
COPY get_num_cores.sh /get_num_cores.sh
COPY example_dags $AIRFLOW_HOME/dags/repo/airflow/
RUN chmod 755 /uid_entrypoint.sh && \
    chmod 755 /get_num_cores.sh

RUN yum -y clean all && rm -rf /var/cache/yum

RUN curl -L -o /usr/local/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
        chmod +x /usr/local/bin/kubectl

RUN mkdir -p ${AIRFLOW_HOME} /git && for f in "${AIRFLOW_HOME}" "/etc/passwd" "/etc/group" "/git"; do\
          chgrp -R 0 ${f} && \
          chmod -R g+rwX ${f} && \
          chmod -R 777 ${AIRFLOW_HOME} /git; \
        done && \
        # Generate passwd.template \
        cat /etc/passwd | \
        sed s#default:x.*#default:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g \
        > /opt/app-root/src/passwd.template && \
        # Generate group.template \
        cat /etc/group | \
        sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g \
        > /opt/app-root/src/group.template && \
        echo "${USER_NAME:-default}:x:1000397777:0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd

USER 1001
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/uid_entrypoint.sh"]
EXPOSE 8080
CMD ["webserver"]
