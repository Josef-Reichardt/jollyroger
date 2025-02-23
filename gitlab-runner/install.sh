microk8s.helm repo remove gitlab
microk8s.helm repo add gitlab https://charts.gitlab.io
microk8s.helm repo update

microk8s.helm --namespace gitlab-runner del nachhaltig-verstoert-content-gitlab-runner
microk8s.helm --namespace gitlab-runner install nachhaltig-verstoert-content-gitlab-runner gitlab/gitlab-runner \
  -f nachhaltig-verstoert-content.yaml \
  -f token-nachhaltig-verstoert.yaml

microk8s.helm --namespace gitlab-runner del creativity-green-group-gitlab-runner
microk8s.helm --namespace gitlab-runner install creativity-green-group-gitlab-runner gitlab/gitlab-runner \
  -f creativity-green-group.yaml \
  -f token-creativity-green.yaml
