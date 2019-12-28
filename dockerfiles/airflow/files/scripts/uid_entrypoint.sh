#!/usr/bin/env bash

if [[ ! ${AIRFLOW__SCHEDULER__MAX_THREADS+x} ]]; then
    # Set default for max threads to the number of cores available on the system.
    # Scheduler as of 1.10.3 performs better with the number of threads exceeded the core count as
    # it's mostly network calls, so this should be manually tuned instead of relying on this.
    AIRFLOW__SCHEDULER__MAX_THREADS=$(/get_num_cores.sh)
fi

if [[ "${AIRFLOW_USE_LDAP_PLUGIN}" == "True" ]]; then
    example-airflow-ldap --install
fi

case "$1" in
  local)
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
    airflow initdb
    airflow scheduler &
    exec airflow "webserver"
    ;;
  scheduler)
    # Run initdb on scheduler startup as scheduler is the only service guaranteed to have a
    # single pod
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
    airflow initdb
    exec airflow "scheduler"
    ;;
  worker)
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
    export C_FORCE_ROOT=true # Celery thinks we're running as root and blocks startup without this
    exec airflow "worker"
    ;;
  flower|version|webserver)
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right
    # environment.
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
    exec "$@"
    ;;
esac
