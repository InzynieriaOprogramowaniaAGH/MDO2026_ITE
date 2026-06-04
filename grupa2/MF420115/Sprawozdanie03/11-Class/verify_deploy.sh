#!/bin/bash
echo "Rozpoczynam automatyczna weryfikacje wdrozenia (Limit: 60s)..."

for i in {1..12}; do
  AVAILABLE=$(kubectl get deployment mdo-deployment -o jsonpath='{.status.availableReplicas}')
  DESIRED=$(kubectl get deployment mdo-deployment -o jsonpath='{.spec.replicas}')

  # Zamiana pustego wyniku na zero (gdy żadna replika nie jest jeszcze gotowa)
  AVAILABLE=${AVAILABLE:-0}

  echo "[Próba $i/12] Aktywne repliki: $AVAILABLE z $DESIRED..."

  if [ "$AVAILABLE" == "$DESIRED" ] && [ "$DESIRED" -gt 0 ]; then
    echo "SUKCES: Wszystkie repliki sa gotowe w wymaganym czasie!"
    exit 0
  fi
  sleep 5
done

echo "BLAD: Wdrozenie przekroczylo limit 60 sekund lub pody maja awarie!"
exit 1
