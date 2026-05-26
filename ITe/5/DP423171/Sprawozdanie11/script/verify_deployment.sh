#!/usr/bin/env sh
NAMESPACE="${1:-default}"
DEPLOYMENT="${2:-speedtest}"
TIMEOUT_SECONDS=60

echo " --- Namespace: ${NAMESPACE}"
echo " --- Deployment: ${DEPLOYMENT}"

printf " --- Rollout history: "
kubectl rollout history deployment.apps/${DEPLOYMENT} -n ${NAMESPACE} || true

printf " --- Current rollout status..."
if STATUS="$(kubectl rollout status deployment.apps/${DEPLOYMENT} -n ${NAMESPACE} --timeout=${TIMEOUT_SECONDS}s)"
then
    echo " OK!"
else
    echo " $STATUS"
    echo " --- Deployment details:"
    kubectl describe deployment.apps/${DEPLOYMENT} -n ${NAMESPACE} || true
    echo " --- Pods:"
    kubectl get pods -n ${NAMESPACE} -o wide || true
    echo " --- Recent events:"
    kubectl get events -n ${NAMESPACE} \
        --sort-by=.metadata.creationTimestamp \
        | tail -20
    exit 1
fi
echo " --- Done!"
