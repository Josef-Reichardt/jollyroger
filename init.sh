#!/bin/bash

if microk8s.status | grep -q "dns: disabled"
then
  echo "### Enable Kubernetes DNS ###"
  microk8s.enable dns
fi;

echo ""
echo "### Install cert-manager ###"
microk8s.helm repo add jetstack https://charts.jetstack.io
microk8s.kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml

kubernetesDashboardPort=
kubernetesDashboardToken=
if microk8s.status | grep -q "dashboard: disabled"
then
  echo ""
  echo "### Enable Kubernetes Dashboard ###"
  microk8s.enable dashboard
  microk8s.kubectl -n kube-system get service kubernetes-dashboard -o yaml >/tmp/kubernetes-dashboard-svc.yaml
  sed '/clusterIP/d;/ClusterIP/d;/^[ ]*ports:/i \  type: NodePort' /tmp/kubernetes-dashboard-svc.yaml >/tmp/kubernetes-dashboard-svc.NodePort.yaml
  microk8s.kubectl apply -f /tmp/kubernetes-dashboard-svc.NodePort.yaml
fi;

echo ""
echo "### Get Kubernetes Service information ###"
kubernetesDashboardPort=$(microk8s.kubectl get all --all-namespaces | grep service/kubernetes-dashboard | sed 's/^.*443:\([0-9]*\)\/TCP.*$/\1/')
echo "### Get Kubernetes Dashboard Token ###"
token=$(microk8s.kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
kubernetesDashboardToken=$(microk8s.kubectl -n kube-system describe secret "$token" | grep "token:" | sed 's/^token:\s*//')

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
  microk8s.helm install "$(dirname "$0")" --name jollyroger \
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
[ -n "$kubernetesDashboardPort" ] && echo "### Kubernetes Dashboard Port: $kubernetesDashboardPort"
[ -n "$kubernetesDashboardToken" ] && echo "### Kubernetes Dashboard Token: $kubernetesDashboardToken"
