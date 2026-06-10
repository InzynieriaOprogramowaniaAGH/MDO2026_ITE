#!/bin/bash
DEPLOYMENT=${1:-express-app}
TIMEOUT=60

echo "Sprawdzam wdrożenie: $DEPLOYMENT (timeout: ${TIMEOUT}s)"

if kubectl rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s; then
    echo "SUCCESS: Wdrożenie $DEPLOYMENT zakończyło się sukcesem w ciągu ${TIMEOUT}s"
    exit 0
else
    echo "FAILED: Wdrożenie $DEPLOYMENT nie zakończyło się w ciągu ${TIMEOUT}s"
    echo "--- Stan podów ---"
    kubectl get pods -l app=$DEPLOYMENT
    echo "--- Ostatnie eventy ---"
    kubectl describe deployment/$DEPLOYMENT | tail -20
    exit 1
fi
