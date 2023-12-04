#!/bin/sh

namespace="flask-application"

# Removing older images for both applications if any exist
echo "------Removal of old images started------"
if docker images -q anishihsag/flask-application; then
docker rmi -f $(docker images -q anishihsag/flask-application)
else
echo "No old images exist"
fi
echo "------Removal of old images completed ------"
# Building new docker image for first application
echo "------Building and pushing of new docker images started------"
docker build -t anishihsag/flask-application:image-to-expose-json app-To-Render-Json/.

# Building new docker image for second application
docker build -t anishihsag/flask-application:image-to-expose-reversed-json app-To-Render-Reverse/.

# Docker login
docker login -u anishihsag -p dckr_pat_sn57rlLpFBqAMc-oXmstwXcAizw

# Pushing docker image for first application to docker hub
docker push anishihsag/flask-application:image-to-expose-json

# Pushing docker image for second application to docker hub
docker push anishihsag/flask-application:image-to-expose-reversed-json
echo "------Building and pushing of new docker images Completed------"

# Create flask-application namespace if it does not exist
echo "------Creation of namespace Started------"

if kubectl get namespace "$namespace" &> /dev/null; then
    echo "Namespace $namespace exists."
else
    kubectl create namespace "$namespace"
fi
echo "------Creation of namespace Completed------"

echo "------Creation of Secrets Started------"
if kubectl get secrets "dockerhub-secret" &> /dev/null; then
    echo " Secret exists."
else
    kubectl create secret generic dockerhub-secret -n $namespace --from-file=.dockerconfigjson=docker-config.json --type=kubernetes.io/dockerconfigjson
fi
echo "------Creation of Secrets Completed------"

# Deploying First application to kubernetes cluster
echo "------Deployment of Both applications started------"
helm upgrade -i -f ./app-To-Render-Json/values.yaml --set imagePullPolicy=Always app-to-render-json deployment_using_helm/. -n "$namespace" --debug
# Deploying Second application to kubernetes cluster
helm upgrade -i -f ./app-To-Render-Reverse/values.yaml --set imagePullPolicy=Always app-to-render-reversed-json deployment_using_helm/. -n "$namespace" --debug
echo "------Deployment of Both applications Completed------"


# Output of First Application

echo "------Printing Output of first application------"
pod_name_for_first_application=$(kubectl get pods -l app=app-to-render -o custom-columns=:metadata.name -n "$namespace" | tail -n 1)
kubectl exec "$pod_name_for_first_application" -n "$namespace" -- curl http://localhost:5002 2>/dev/null

# Output of Second Application
echo "------Printing Output of Second application------"
pod_name_for_second_application=$(kubectl get pods -l app=app-to-render-reversed-json -o custom-columns=:metadata.name -n "$namespace" | tail -n 1)
kubectl exec "$pod_name_for_second_application" -n "$namespace" -- curl http://localhost:5001 2>/dev/null

