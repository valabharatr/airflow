# VERSION 1.10.1
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/puckel/docker-airflow

# Disclaimer: I take no credit for this Dockerfile. It is a copy of the original
# with a minor change to have git available. Please start from the original Dockerfile
# for your own setup.

#FROM python:3.6-slim
FROM centos/python-36-centos7:latest
LABEL maintainer="Puckel_"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
ENV LD_LIBRARY_PATH=/opt/rh/rh-python36/root/usr/lib64
# Airflow
ARG AIRFLOW_VERSION
ARG AIRFLOW_HOME
ARG AIRFLOW_DEPS
ARG PYTHON_DEPS
ARG KUBECTL_VERSION
ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
USER root
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
    && pip install apache-airflow[async,kubernetes,s3,statsd,crypto,celery,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}] \
    && pip install 'redis>=2.10.5,<3' \
    && pip install async celery crypto kubernetes mysql s3 statsd python-ldap mysqlclient flask_bcrypt plotly scipy seaborn theano openpyxl tensorflow keras sklearn h5py jellyfish tldextract joypy python-Levenshtein matplotlib yara-python pillow requests networkx \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && yum remove -y $buildDeps \
    && yum clean all
ENV HOME ${AIRFLOW_HOME}
ENV AIRFLOW_HOME ${AIRFLOW_HOME}
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
        > /opt/app-root/src/group.template
RUN yum install nmap-ncat -y
RUN curl -L -o /usr/local/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
        chmod +x /usr/local/bin/kubectl
COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/usr/local/airflow.cfg
COPY example_dags ${AIRFLOW_HOME}/dags/repo/airflow/
USER root
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]
