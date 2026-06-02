#!/bin/bash

RG="rg-ds419547-mdo"

echo "Usuwanie grupy $RG..."
az group delete --name $RG --yes --no-wait

echo "Zlecenie wyslane. Grupa zostanie usunieta w tle."

