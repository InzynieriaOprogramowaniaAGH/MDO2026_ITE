#!/bin/bash

if minikube kubectl -- rollout status deployment app-deployment --timeout=60s; then
    echo "OK - t <= 60s"
    exit 0
else
    echo "Błąd - t > 60s"
    exit 1
fi
