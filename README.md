## AirFlow Deployment on OpenShift

## How to Setup Airflow
# Build Docker image for Mariadb
$ cd dockerfiles/mariadb

$ docker build --tag=docker-registry-default.isvapps-poc.yourdomain.com/default/mariadb:latest --file Dockerfile .

$ docker tag docker-registry-default.isvapps-poc.yourdomain.com/default/mariadb:latest docker-registry.default.svc:5000/default/mariadb:latest

$ docker push docker-registry.default.svc:5000/default/mariadb:latest

# Build Docker image for Airflow
$ bash dockerfiles/airflow/build-docker.sh \
  --image=docker-registry-default.isvapps-poc.yourdomain.com/default/airflow-asis \
  --tag=1.5 \
  --home=/opt/airflow \
  --version=1.10.5 \
  --kubectl-version=1.10.0

# Create Tag
$ docker tag \
  docker-registry-default.isvapps-poc.yourdomain.com/default/airflow-asis:1.5 \
  docker-registry.default.svc:5000/default/airflow-asis:1.5

# Push the Docker Image
$ docker push docker-registry.default.svc:5000/default/airflow-asis:1.5

# Switch to the project you want to deploy Airflow Application
$ oc project afasis

# Allow privileges to the airflow-cluster-access service account required for Scheduler Pod
$ oc adm policy add-scc-to-user privileged --serviceaccount=airflow-cluster-access

# Allow privileges to the default service account required for Web and Maridb Pod
$ oc adm policy add-scc-to-user privileged --serviceaccount=default

# Run the Script to deploy the Airflow Application
$ bash run.sh \
  --image=docker-registry-default.isvapps-poc.yourdomain.com/default/airflow-asis:1.5 \
  --db-image=docker-registry-default.isvapps-poc.yourdomain.com/default/mariadb:10.4 \
  --home=/opt/airflow \
  --project=afasis \
  --wait
