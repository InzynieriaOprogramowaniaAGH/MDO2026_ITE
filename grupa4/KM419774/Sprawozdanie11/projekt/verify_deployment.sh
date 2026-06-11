#!/bin/bash

kubectl rollout status deployment/moja-apka --timeout=60s

if [ $? -eq 0 ]
then
    echo "Deployment OK"
else
    echo "Deployment FAILED"
fi
