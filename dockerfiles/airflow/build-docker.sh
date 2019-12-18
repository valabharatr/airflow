#!/bin/bash

for var in "$@"
do
echo $var
  case $var in
    -i=*| --image=*)
      AF_IMAGE="${var#*=}"
      shift
      ;;
    -t=*| --tag=*)
      AF_TAG="${var#*=}"
      shift
      ;;
    -h=*| --home=*)                                                                                                    
      AF_HOME="${var#*=}"                                                                                      
      shift                                                                                                        
      ;;                                                                                                           
    -v=*| --version=*)                                                                                                   
      AF_VERSION="${var#*=}"                                                                                      
      shift                                                                                                        
      ;;
    -k=*| --kubectl-version=*)                                                                                                   
      KUBECTL_VERSION="${var#*=}"                                                                                      
      shift                                                                                                        
      ;;
    *)                                                                                                             
      echo "Unknown argument passed: '$var'."
      exit 1                                                                                                       
      ;;                                                                                                           
  esac                                                                                                             
done

IMAGE=${AF_IMAGE:-airflow}
TAG=${AF_TAG:-latest}
AIRFLOW_HOME=${AF_HOME:-/usr/local/airflow}
AIRFLOW_VERSION=${AF_VERSION:-1.10.6}
KUBECTL_VERSION=${KUBECTL_VERSION:-1.11.0}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rm -rf .tmp/

mkdir -p .tmp && cd .tmp
git clone https://github.com/puckel/docker-airflow.git
cp $DIR/Dockerfile docker-airflow/Dockerfile
cp $DIR/entrypoint.sh docker-airflow/script/entrypoint.sh
cp -r $DIR/example_dags docker-airflow/
cd docker-airflow

docker build --build-arg PYTHON_DEPS="Flask-OAuthlib" --build-arg AIRFLOW_DEPS="kubernetes" --build-arg AIRFLOW_VERSION="${AIRFLOW_VERSION}" --build-arg KUBECTL_VERSION="${KUBECTL_VERSION}" --build-arg AIRFLOW_HOME="${AIRFLOW_HOME}" --tag=${IMAGE}:${TAG} .

cd ../..
rm -rf .tmp/
