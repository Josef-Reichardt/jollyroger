microk8s.helm repo remove gitlab
microk8s.helm repo add gitlab https://charts.gitlab.io
microk8s.helm repo update
microk8s.helm --namespace gitlab-runner del nachhaltig-verstoert-content-gitlab-runner
microk8s.helm --namespace gitlab-runner install nachhaltig-verstoert-content-gitlab-runner gitlab/gitlab-runner \
  -f nachhaltig-verstoert-content.yaml \
  -f token.yaml
