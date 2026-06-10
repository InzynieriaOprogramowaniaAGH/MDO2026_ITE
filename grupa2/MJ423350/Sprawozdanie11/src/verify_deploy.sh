#!/bin/bash

DEPLOYMENT_NAME="node-deployment"
TIMEOUT_SECONDS=60

if timeout ${TIMEOUT_SECONDS} minikube kubectl -- rollout status deployment/${DEPLOYMENT_NAME}; then
    echo "Wdrożenie zakończyło się pomyślnie w wyznaczonym czasie!"
    exit 0
else
    echo "Wdrożenie przekroczyło limit czasu ${TIMEOUT_SECONDS} sekund lub uległo awarii!"
    exit 1
fi