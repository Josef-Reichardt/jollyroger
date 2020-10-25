
if microk8s.helm list --namespace gitlab-runner | grep -q gitlab-runner
then
  microk8s.helm repo add gitlab https://charts.gitlab.io
  microk8s.helm init
  microk8s.helm install --namespace gitlab-runner -name gitlab-runner -f values.yaml gitlab/gitlab-runner
else
  microk8s.helm upgrade --namespace gitlab-runner -f values.yaml gitlab-runner gitlab/gitlab-runner
fi;
