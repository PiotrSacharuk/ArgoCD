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

echo "Creating ArgoCD cluster: ${ARGOCD_CLUSTER_NAME}"

k3d cluster create ${ARGOCD_CLUSTER_NAME} --config ./cluster-config.yaml

# Ensure kubectl context is set to the new cluster
echo "Setting kubectl context to k3d-${ARGOCD_CLUSTER_NAME}..."
kubectl config use-context k3d-${ARGOCD_CLUSTER_NAME}

# Verify cluster connection
echo "Verifying cluster connection..."
kubectl get nodes
kubectl cluster-info
