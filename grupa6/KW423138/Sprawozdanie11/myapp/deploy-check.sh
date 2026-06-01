#!/bin/bash

DEPLOYMENT=myapp-deployment
TIMEOUT=60s

kubectl rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT

if [ $? -eq 0 ]; then
    echo "Deployment OK"
    exit 0
else
    echo "Deployment FAILED"
    exit 1
fi
