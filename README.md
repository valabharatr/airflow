## AirFlow Deployment on OpenShift

## How to Setup Airflow
# Build Docker image for Mariadb

$ cd dockerfiles/mariadb

$ docker build \
  --no-cache \
  --tag=docker-registry-default.isvapps-poc.yourdomain.com/default/mariadb:latest \
  --file Dockerfile .

$ docker tag docker-registry-default.isvapps-poc.yourdomain.com/default/mariadb:latest docker-registry.default.svc:5000/default/mariadb:latest

$ docker push docker-registry.default.svc:5000/default/mariadb:latest

$ cd ../..

# Build Docker image for Airflow

$ cd dockerfiles/airflow

$ docker build \
     --no-cache \
     --build-arg PYTHON_DEPS="Flask-OAuthlib" \
     --build-arg AIRFLOW_DEPS="kubernetes" \
     --build-arg AIRFLOW_VERSION="1.10.5" \
     --build-arg KUBECTL_VERSION="1.11.0" \
     --build-arg AIRFLOW_HOME="/opt/airflow" \
     --tag=docker-registry-default.isvapps-poc.yourdomain.com/default/af:1.10 .

$ cd ../..

# Create Tag
$ docker tag \
  docker-registry-default.isvapps-poc.yourdomain.com/default/af:1.10 \
  docker-registry.default.svc:5000/default/af:1.10

# Push the Docker Image
$ docker push docker-registry.default.svc:5000/default/af:1.10

# Switch to the project you want to deploy Airflow Application
$ oc project afv7

# Run the Script to deploy the Airflow Application
$ bash run.sh \
  --image=docker-registry-default.isvapps-poc.yourdomain.com/default/af:1.10 \
  --db-image=docker-registry-default.isvapps-poc.yourdomain.com/default/mariadb:latest \
  --home=/opt/airflow \
  --project=afv7 \
  --wait
