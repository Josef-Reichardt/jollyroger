#!/bin/bash

if microk8s.status | grep -q "dns: disabled"
then
  echo "### Enable Kubernetes DNS ###"
  microk8s.enable dns
fi;

echo ""
echo "### Install cert-manager ###"
microk8s.helm repo add jetstack https://charts.jetstack.io
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

initialDatabaseRootPassword=
databasePassword=
initialNextcloudAdminPassword=
if microk8s.helm list | grep -q jollyroger
then
  echo ""
  echo "### Upgrade Helm Chart ###"
  initialDatabaseRootPassword=$(microk8s.kubectl get secret mariadb-secrets -o yaml | grep MYSQL_ROOT_PASSWORD | sed 's/^.*: "\?\(.*\)"\?$/\1/' | base64 -d)
  databasePassword=$(microk8s.kubectl get secret mariadb-secrets -o yaml | grep MYSQL_PASSWORD | sed 's/^.*: "\?\(.*\)"\?$/\1/' | base64 -d)
  initialNextcloudAdminPassword=$(microk8s.kubectl get secret nextcloud-secrets -o yaml | grep NEXTCLOUD_ADMIN_PASSWORD | sed 's/^.*: "\?\(.*\)"\?$/\1/' | base64 -d)
  microk8s.helm upgrade jollyroger "$(dirname "$0")" \
    --set "mariadb.initialRootPassword=$initialDatabaseRootPassword" \
    --set "mariadb.password=$databasePassword" \
    --set "nextcloud.initialAdminPassword=$initialNextcloudAdminPassword" \
    --set ingressShim.defaultIssuerName=jollyroger-letsencrypt-issuer \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    --set ingressShim.defaultIssuerGroup=cert-manager.io \
    -f base.yaml \
    -f values.yaml
else
  echo ""
  echo "### Deploy Helm Chart ###"
  initialDatabaseRootPassword=$(head -c 24 /dev/random | base64)
  databasePassword=$(head -c 24 /dev/random | base64)
  initialNextcloudAdminPassword=$(head -c 24 /dev/random | base64)
  microk8s.helm install jollyroger "$(dirname "$0")" \
    --set "mariadb.initialRootPassword=$initialDatabaseRootPassword" \
    --set "mariadb.password=$databasePassword" \
    --set "nextcloud.initialAdminPassword=$initialNextcloudAdminPassword" \
    --set ingressShim.defaultIssuerName=jollyroger-letsencrypt-issuer \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    --set ingressShim.defaultIssuerGroup=cert-manager.io \
    -f base.yaml \
    -f values.yaml
fi;

echo ""
echo "################################################################################"
[ -n "$initialDatabaseRootPassword" ] && echo "### Initial Database Root Password: $initialDatabaseRootPassword"
[ -n "$databasePassword" ] && echo "### Database Password:  $databasePassword"
[ -n "$initialNextcloudAdminPassword" ] && echo "### Initial Nextcloud Admin Password: $initialNextcloudAdminPassword"
