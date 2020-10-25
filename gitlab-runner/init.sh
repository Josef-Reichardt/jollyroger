
if microk8s.helm list --namespace gitlab-runner | grep -q gitlab-runner
then
  helm repo add gitlab https://charts.gitlab.io
  helm init
  helm install --namespace gitlab-runner -name gitlab-runner -f values.yaml gitlab/gitlab-runner
else
  helm upgrade --namespace gitlab-runner -f values.yaml gitlab-runner gitlab/gitlab-runner
fi;
