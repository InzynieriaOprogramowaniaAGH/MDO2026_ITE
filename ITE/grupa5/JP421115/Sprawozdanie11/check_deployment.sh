#!/bin/bash
DEPLOYMENT_NAME="nginx-deployment"
TIMEOUT=60
INTERVAL=5
ELAPSED=0

echo "MONITORING WDROZENIA: $DEPLOYMENT_NAME"

while [ $ELAPSED -lt $TIMEOUT ]; do
  if kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=5s > /dev/null 2>&1; then
    echo "[OK] Wdrozenie zakonczone pomyslnie w czasie $ELAPSED sekund!"
    exit 0
  fi

  echo "Wdrozenie w toku... Czekam ($ELAPSED / $TIMEOUT sek)"
  sleep $INTERVAL
  let ELAPSED+=$INTERVAL
done

echo "[FAIL] Timeout! Wdrozenie nie udalo sie w ciagu $TIMEOUT sekund."
exit 1
