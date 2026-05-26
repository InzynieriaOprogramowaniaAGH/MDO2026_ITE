#!/bin/bash

NAMESPACE="proton"
TIMEOUT="60s"

FAILED=0

DEPLOYMENTS=$(kubectl -n $NAMESPACE get deployments -o jsonpath='{.items[*].metadata.name}')

for DEPLOYMENT in $DEPLOYMENTS; do
    echo "Checking deployment: $DEPLOYMENT"

    if kubectl rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=$TIMEOUT
    then
        echo "STATUS: ✅ $DEPLOYMENT"
    else
        echo "STATUS: ❌ $DEPLOYMENT"
        FAILED=1
    fi

    echo ""
done

exit $FAILED