#!/bin/bash
DEPLOYMENT="kinsu-deployment"
TIMEOUT="60s"

echo ">>> Weryfikacja: $DEPLOYMENT (limit: $TIMEOUT) <<<"

if kubectl rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT; then
    echo ">>> wdrożenie zakończyło się pomyślnie <<<"
    exit 0
else
    echo ">>> wdrożenie nie zdążyło się wykonać w ciągu $TIMEOUT! <<<"
    exit 1
fi
