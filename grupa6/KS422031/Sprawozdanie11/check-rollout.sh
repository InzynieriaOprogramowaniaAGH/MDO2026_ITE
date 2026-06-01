#!/bin/bash

DEPLOYMENT="kacper-nginx-deployment"
TIMEOUT="60s"

echo "Sprawdzanie wdrozenia: $DEPLOYMENT"
kubectl rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT

if [ $? -eq 0 ]; then
    echo "Deployment wdrozyl sie poprawnie w czasie $TIMEOUT"
    exit 0
else
    echo "Deployment NIE wdrozyl sie w czasie $TIMEOUT"
    kubectl get deployment,pods -o wide
    exit 1
fi
