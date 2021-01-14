microk8s.helm repo add gitlab https://charts.gitlab.io
microk8s.helm repo update
microk8s.helm install gitlab/gitlab-runner --namespace gitlab-runner --name nachhaltig-verstoert-content-gitlab-runner -f nachhaltig-verstoert-content.yaml
