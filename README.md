Setup for my personal Intel NUC running Ubuntu Server:

* Nextcloud
* MariaDB
* nginx
* let's encrypt

## Requirements
* microk8s
* helm

## Install

Simply run `init.sh`.

This will do:

1. Enable kubernetes dns if not already enabled
2. Enable kubernetes dashboard if not already enabled  
   In case of newly enabled:
   1. Determine port for dashboard
   2. Determine token for dashboard
3. Install or upgrade helm chart  
   In case of a new install random passwords will be generated for
   1. initial database user `root`
   2. initial database user `nextcloud`
   3. initial nextcloud user `admin`
4. Display Infos:
   1. dashboard port & token
   2. initial passwords of database users `root` & `nextcloud`
   3. initial passwords of nextcloud user `admin`

## Kubernetes Metrics Service

Install:

```shell
kubectl apply -f metrics-service/components.yaml
```
