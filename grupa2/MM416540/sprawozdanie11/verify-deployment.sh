#!/bin/bash
DEPLOYMENT=$1
TIMEOUT=60
INTERVAL=5
ELAPSED=0

if [ -z "$DEPLOYMENT" ]; then
  echo "Użycie: $0 <nazwa-deploymentu>"
  exit 1
fi

echo "Weryfikacja wdrożenia: $DEPLOYMENT (timeout: ${TIMEOUT}s)"

while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(kubectl rollout status deployment/$DEPLOYMENT --timeout=5s 2>&1)

  if echo "$STATUS" | grep -q "successfully rolled out"; then
    echo "✅ Wdrożenie zakończone sukcesem po ${ELAPSED}s"
    kubectl get pods -l app=$DEPLOYMENT
    exit 0
  fi

  echo "⏳ Czekam... (${ELAPSED}s / ${TIMEOUT}s)"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "❌ Wdrożenie NIE zakończyło się w ciągu ${TIMEOUT}s"
kubectl get pods
kubectl rollout history deployment/$DEPLOYMENT
exit 1