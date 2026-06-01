#!/bin/bash
DEPLOYMENT="$1"
if [ -z "$DEPLOYMENT" ]; then
  echo "Uzycie: $0 <deployment>"
  exit 1
fi
minikube kubectl -- rollout status deployment/"$DEPLOYMENT" --timeout=60s
STATUS=$?
if [ $STATUS -eq 0 ]; then
  echo "Wdrozenie zakonczone sukcesem. Czas <= 60s"
else
  echo "Wdrozenie nie zakonczylo sie sukcesem. Czas > 60s"
fi
exit $STATUS