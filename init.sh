#!/bin/bash

if microk8s.status | grep -q "dns: disabled"
then
  echo "### Enable Kubernetes DNS ###"
  microk8s.enable dns
fi;

echo ""
echo "### Prepare helm repos ###"
microk8s.helm repo add jetstack https://charts.jetstack.io
microk8s.helm repo add community-charts https://community-charts.github.io/helm-charts
microk8s.helm repo update

echo ""
echo "### Install cert-manager ###"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

initialDatabaseRootPassword=
databasePassword=
initialNextcloudAdminPassword=
if microk8s.helm list | grep -q jollyroger
then
  echo ""
  echo "### Upgrade Helm Chart ###"

  initialDatabaseRootPassword=$(microk8s.kubectl get secret mariadb-secrets -o yaml 2>/dev/null | grep MYSQL_ROOT_PASSWORD | sed 's/^.*: "\?\(.*\)"\?$/\1/' | base64 -d 2>/dev/null)
  initialDatabaseRootPassword=${initialDatabaseRootPassword:-"changeme"}

  databasePassword=$(microk8s.kubectl get secret mariadb-secrets -o yaml 2>/dev/null | grep MYSQL_PASSWORD | sed 's/^.*: "\?\(.*\)"\?$/\1/' | base64 -d 2>/dev/null)
  databasePassword=${databasePassword:-"changeme"}

  initialNextcloudAdminPassword=$(microk8s.kubectl get secret nextcloud-secrets -o yaml 2>/dev/null | grep NEXTCLOUD_ADMIN_PASSWORD | sed 's/^.*: "\?\(.*\)"\?$/\1/' | base64 -d 2>/dev/null)
  initialNextcloudAdminPassword=${initialNextcloudAdminPassword:-"changeme"}

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

echo ""
echo "### install n8n ###"
microk8s.helm upgrade --install n8n community-charts/n8n -f n8n-base.yaml -f n8n.yaml

echo ""
echo "### install image-construction-service ###"
microk8s.helm upgrade --install image-construction-service \
  --repo https://gitlab.com/api/v4/projects/creativity.green%2Ftools%2Fimg-construction-service/packages/helm/stable \
  image-construction-service \
  --version 1.2.5

echo ""
echo "### install invoice ninja ###"
microk8s.helm upgrade --install invoiceninja "$(dirname "$0")/invoiceninja" \
  -f "$(dirname "$0")/invoiceninja/values.yaml" \
  -f invoiceninja.yaml
