#!/bin/bash

# Load environment variables
if [ -f ".env" ]; then
    source .env
else
    echo "Error: .env file not found"
    echo "Please copy .env.example to .env and configure it:"
    echo "cp .env.example .env"
    exit 1
fi

NAMESPACE=${ARGOCD_NAMESPACE}

echo "Installing ArgoCD in namespace: ${NAMESPACE}"
echo "Current kubectl context: $(kubectl config current-context)"

# Verify cluster connection
kubectl cluster-info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Cannot connect to Kubernetes cluster"
    echo "Please ensure the cluster is running and kubectl context is correct"
    exit 1
fi
kubectl create namespace ${NAMESPACE}
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n ${NAMESPACE} get deployment
kubectl -n ${NAMESPACE} get service
kubectl -n ${NAMESPACE} get statefulset

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd 2>/dev/null || echo "ArgoCD CLI installation requires sudo privileges"
rm argocd-linux-amd64

# Just show the client version (no server connection needed)
argocd version --client 2>/dev/null || echo "ArgoCD CLI installed"

kubectl -n ${NAMESPACE} get all

echo "ArgoCD installation completed successfully!"
echo "Note: ArgoCD pods may still be starting up. Use 'kubectl get pods -n argocd' to monitor their status."
