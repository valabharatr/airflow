from datetime import timedelta

from sqlalchemy import func

"""
https://github.com/apache/airflow/blob/16d93c9e45e14179c7822fed248743f0c3fd935c/airflow/www_rbac/views.py#L153

Script that can be used to check if scheduler running correctly as it can sometimes gets stuck 
unable to schedule new tasks despite the process looking healthy. 

This imitates the logic that exists in the airflow webservers health check endpoint, but runs 
locally so it can be used as a simple pod livenessProbe.


Example of usage by a livenessProbe inside a kubernetes pod spec ::

    livenessProbe:
      exec:
        command:
        - python3
        - /path/to/script/scheduler_health_check.py
      periodSeconds: 300
      timeoutSeconds: 15

"""


def main():
    # Inline the airflow imports because they cause the global config to be loaded
    from airflow.utils import timezone
    from airflow import jobs
    from airflow.configuration import conf
    from airflow.settings import configure_orm, Session

    configure_orm(disable_connection_pool=True)

    base_job_model = jobs.BaseJob
    scheduler_health_check_threshold = timedelta(
        seconds=conf.getint('scheduler', 'scheduler_health_check_threshold')
    )

    latest_scheduler_heartbeat = None
    try:

        latest_scheduler_heartbeat = (
            Session.query(func.max(base_job_model.latest_heartbeat))
            .filter(base_job_model.state == 'running', base_job_model.job_type == 'SchedulerJob')
            .scalar()
        )
    except Exception:
        pass

    if not latest_scheduler_heartbeat:
        status_code = 1
    else:
        if timezone.utcnow() - latest_scheduler_heartbeat <= scheduler_health_check_threshold:
            status_code = 0
        else:
            status_code = 1

    return status_code


if __name__ == "__main__":
    exit(main())

