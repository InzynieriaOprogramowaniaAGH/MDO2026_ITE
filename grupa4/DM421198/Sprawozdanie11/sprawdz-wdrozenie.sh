#!/bin/bash

DEPLOYMENT="moja-aplikacja-deploy"
TIMEOUT="60s"

echo " Rozpoczynam weryfikację wdrożenia: $DEPLOYMENT"
echo "Limit czasu: $TIMEOUT"

if kubectl rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT; then
    echo " SUKCES: Aplikacja została pomyślnie wdrożona w wyznaczonym czasie!"
    exit 0
else
    echo " BŁĄD: Czas na wdrożenie upłynął (powyżej 60 sekund) lub wystąpił krytyczny błąd!"

    exit 1
fi
