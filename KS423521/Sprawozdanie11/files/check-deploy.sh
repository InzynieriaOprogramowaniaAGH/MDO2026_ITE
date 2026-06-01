#!/bin/bash
 
DEPLOYMENT="myapp"
TIMEOUT=60
 
echo "Weryfikacja wdrożenia: $DEPLOYMENT (limit: ${TIMEOUT}s)"
 
if kubectl rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s; then
    echo "Wdrożenie zakończone sukcesem."
    exit 0
else
    echo "Wdrożenie nie zakończyło się w ciągu ${TIMEOUT}s – rollback."
    kubectl rollout undo deployment/$DEPLOYMENT
    exit 1
fi