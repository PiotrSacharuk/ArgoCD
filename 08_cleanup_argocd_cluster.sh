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

echo "Cleaning up ArgoCD cluster environment..."

# Stop ArgoCD WebUI if running
echo "Stopping ArgoCD WebUI processes..."
pkill -f "kubectl port-forward.*argocd-server" 2>/dev/null && echo "Stopped ArgoCD port-forward" || echo "No ArgoCD port-forward running"

# Check if argocd-cluster exists
if k3d cluster list | grep -q "${ARGOCD_CLUSTER_NAME}"; then
    echo "Deleting k3d cluster: ${ARGOCD_CLUSTER_NAME}"
    k3d cluster delete ${ARGOCD_CLUSTER_NAME}
    echo "Cluster ${ARGOCD_CLUSTER_NAME} deleted successfully"
else
    echo "Cluster ${ARGOCD_CLUSTER_NAME} not found"
fi

# Remove any ArgoCD related secrets or configs that might be cached
echo ""
echo "Cleaning up potential ArgoCD artifacts..."

# Remove ArgoCD CLI config if it exists
if [ -f ~/.argocd/config ]; then
    echo "Removing ArgoCD CLI config"
    rm -rf ~/.argocd/
    echo "ArgoCD CLI config removed"
else
    echo "No ArgoCD CLI config found"
fi

# List remaining clusters
echo ""
echo "Remaining k3d clusters:"
k3d cluster list

echo ""
echo "ArgoCD cluster cleanup completed!"
echo "You can recreate it with:"
echo "./02_create_cluster.sh"
echo "./03_install_argocd_svc.sh"
echo "./04_run_argocd_webui.sh"