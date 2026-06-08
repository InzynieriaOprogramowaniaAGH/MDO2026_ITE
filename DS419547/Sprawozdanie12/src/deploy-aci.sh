#!/bin/bash

RG="rg-ds419547-mdo"
LOC="westeurope"
NAME="nestjs-app-aci"
IMG="razeee/nestjs-app-ds419547:12"
DNS="ds419547-app"

az group create --name $RG --location $LOC

az container create \
    --resource-group $RG \
    --name $NAME \
    --image $IMG \
    --dns-name-label $DNS \
    --ports 3000 \
    --ip-address public \
    --location $LOC \
    --os-type Linux \
    --cpu 1 \
    --memory 1.5

az container show \
    --resource-group $RG \
    --name $NAME \
    --query "{FQDN:ipAddress.fqdn,State:provisioningState,IP:ipAddress.ip}" \
    --out table

az container logs --resource-group $RG --name $NAME
