#!/bin/bash

minikube kubectl -- rollout status deployment/mf419850-web --timeout=60s

if [ $? -eq 0 ]; then
    echo "Deployment OK"
else
    echo "Deployment FAILED"
fi
