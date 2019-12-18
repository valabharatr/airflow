#!/bin/bash

HELP="
Usage:
 $0 [options]
Options:
 -i,    --image              image to to deploy, e.g. -i=myartifactory.com/myorg/myimage:mytag. Defaults to serverbee/airflow. Optional.
 -p,    --project            OpenShift project to deploy airflow to. The project must exist. The script will exit if the project does not exist. Mandatory
 -w,    --wait               wait for deployments to be scaled to 1. Timeout is 300 seconds. Optional
 -h,    --help               show this help
"

if [[ $# -eq 0 ]] ; then
  echo -e "$HELP"
  exit 0
fi

for key in "$@"
do
  case $key in
    -i=*| --image=*)
      AIRFLOW_IMAGE="${key#*=}"
      shift
      ;;
    -p=*| --project=*)
      AIRFLOW_NAMESPACE="${key#*=}"
      shift
      ;;
    -w| --wait)
      WAIT_FOR_AIRFLOW="true"
      shift
      ;;
    -h | --help)
      echo -e "$HELP"
      exit 1
      ;;
    *)
      echo "Unknown argument passed: '$key'."
      echo -e "$HELP"
      exit 1
      ;;
  esac
done

if [ -z "$AIRFLOW_NAMESPACE" ]
  then
    echo -e "
Missing mandatory argument -p=\$PROJECT.
Rerun the stript with -p=\$DOMAIN flag"
    exit 1
fi

DEFAULT_AIRFLOW_IMAGE="serverbee/airflow:latest"
AIRFLOW_IMAGE=${AIRFLOW_IMAGE:-${DEFAULT_AIRFLOW_IMAGE}}

printInfo() {
  echo "[INFO]: ${1}"
}

printWarning() {
  echo "[WARNING]: ${1}"
}

printError() {
  echo "[ERROR]: ${1}"
  exit 1
}

beautify() {
  sed 's/^/        /'
}

checkNamespace() {

  printInfo "Checking if project '${AIRFLOW_NAMESPACE}' exists"
  oc get namespace ${AIRFLOW_NAMESPACE}  > /dev/null || printError "Namespace '${AIRFLOW_NAMESPACE}' does not exist or current user does not have access to it"
}

checkNamespaceUID() {
  printInfo "Getting UID range in project '${AIRFLOW_NAMESPACE}'"
  NAMESPACE_UID=$(oc get namespace/${AIRFLOW_NAMESPACE} -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}' | cut -d'/' -f1)
  if [ -z ${NAMESPACE_UID} ]; then
    printError "Failed to get UID range for project '${AIRFLOW_NAMESPACE}'"
    exit 1
  else
    printInfo "UID range in project '${AIRFLOW_NAMESPACE}' starts with '${NAMESPACE_UID}'"
fi
}

waitForDeployment() {
  DEPLOYMENT=$1
  REQUIRED_COUNT=1
  TIMEOUT=300
  printInfo "Waiting for deployment/${DEPLOYMENT}. Expecting $REQUIRED_COUNT replicas. Timeout in $TIMEOUT seconds"
  CUNNRENT_COUNT=$(oc get deployment/${DEPLOYMENT} -n ${AIRFLOW_NAMESPACE} -o=jsonpath='{.status.availableReplicas}')
  if [ $? -ne 0 ]; then
    printError "An error occurred. Exiting"
    exit 1
  fi
  SLEEP=5
  exit=$((SECONDS+TIMEOUT))
  while [ -z "${CUNNRENT_COUNT}" ] && [ ${SECONDS} -lt ${exit} ]; do
    CUNNRENT_COUNT=$(oc get deployment/${DEPLOYMENT} -n ${AIRFLOW_NAMESPACE} -o=jsonpath='{.status.availableReplicas}')
    timeout_in=$((exit-SECONDS))
    sleep ${SLEEP}
  done

  if [ "${CUNNRENT_COUNT}" -ne "${REQUIRED_COUNT}"  ]; then
    printError "Failed to verify deployment/${DEPLOYMENT} in ${AIRFLOW_NAMESPACE}"
    exit 1
  elif [ ${SECONDS} -ge ${exit} ]; then
    printError "Deployment '${DEPLOYMENT}' timed out. Current replicas is ${CUNNRENT_COUNT}"
    exit 1
  fi
  printInfo "Deployment '${DEPLOYMENT}' successfully scaled to ${CUNNRENT_COUNT}"
}

deploy() {

  printInfo "Deploying Airflow to project '${AIRFLOW_NAMESPACE}' using '${AIRFLOW_IMAGE}'"
  printInfo "Deploying Postgres"
  oc apply -f postgres/ -n ${AIRFLOW_NAMESPACE} | beautify
  waitForDeployment postgres
  printInfo "Creating secrets"
  oc apply -f secrets/ -n ${AIRFLOW_NAMESPACE} | beautify
  printInfo "Creating ConfigMaps. Namespace for DAGs: ${AIRFLOW_NAMESPACE}. Run pods as user: ${NAMESPACE_UID}"
  cat configmaps/airflow-config-cm.yaml | sed "s/\${AIRFLOW_NAMESPACE}/${AIRFLOW_NAMESPACE}/g" | sed "s/\${NAMESPACE_UID}/${NAMESPACE_UID}/g" | oc apply -f - -n ${AIRFLOW_NAMESPACE} | beautify
  oc apply -f configmaps/airflow-init-cm.yaml -n ${AIRFLOW_NAMESPACE} | beautify
  printInfo "Creating service account and rolebinding to be able to schedule DAG pods in project '${AIRFLOW_NAMESPACE}'"
  cat rbac/airflow-cluster-access-crb.yaml | sed "s/\${AIRFLOW_NAMESPACE}/${AIRFLOW_NAMESPACE}/g" | oc apply -f - -n ${AIRFLOW_NAMESPACE} | beautify
  oc apply -f rbac/airflow-cluster-access-sa.yaml -n ${AIRFLOW_NAMESPACE} | beautify
  printInfo "Deploying scheduler"
  oc apply -f sheduler/airflow-logs-pvc.yaml -n ${AIRFLOW_NAMESPACE} | beautify
  cat sheduler/airflow-scheduler.yaml | sed "s@\${AIRFLOW_IMAGE}@${AIRFLOW_IMAGE}@g" | oc apply -f - -n ${AIRFLOW_NAMESPACE} | beautify
  cat web/airflow-web.yaml | sed "s@\${AIRFLOW_IMAGE}@${AIRFLOW_IMAGE}@g" | oc apply -f - -n ${AIRFLOW_NAMESPACE} | beautify
  printInfo "Deploying web client"
  oc apply -f web/airflow-web-svc.yaml -n ${AIRFLOW_NAMESPACE} | beautify
  oc apply -f web/airflow-web-route.yaml -n ${AIRFLOW_NAMESPACE} | beautify

}

waitForAirflow() {
  AIRFLOW_ROUTE=$(oc get routes/airflow-web -o=jsonpath='{.spec.host}' -n ${AIRFLOW_NAMESPACE})
  if [ "${WAIT_FOR_AIRFLOW}" == "true" ]; then
    waitForDeployment airflow-scheduler
    waitForDeployment airflow-web
     printInfo "Airflow is available at http://${AIRFLOW_ROUTE}"
     printInfo "You may also use NodePort to access Airflow Web at http://\$openshift_clister_ip:30965"
   else
     printInfo "Airflow will be available at http://${AIRFLOW_ROUTE}"
     printInfo "You may also use NodePort to access Airflow Web at http://\$openshift_clister_ip:30965"
   fi
}

checkNamespace
checkNamespaceUID
deploy
waitForAirflow
