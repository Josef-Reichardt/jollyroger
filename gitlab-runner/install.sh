microk8s.helm repo add gitlab https://charts.gitlab.io
microk8s.helm repo update
microk8s.helm init
microk8s.helm install --namespace gitlab-runner -name gitlab-runner -f values.yaml gitlab/gitlab-runner
