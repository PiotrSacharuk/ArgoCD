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

echo "Cleaning up dev-cluster environment..."

# Check if dev-cluster exists
if k3d cluster list | grep -q "${DEV_CLUSTER_NAME}"; then
    echo "Deleting k3d cluster: ${DEV_CLUSTER_NAME}"
    k3d cluster delete ${DEV_CLUSTER_NAME}
    echo "Cluster ${DEV_CLUSTER_NAME} deleted successfully"
else
    echo "Cluster ${DEV_CLUSTER_NAME} not found"
fi

# Remove generated config file
if [ -f "dev-cluster-config.yaml" ]; then
    echo "Removing dev-cluster-config.yaml"
    rm dev-cluster-config.yaml
    echo "Config file removed"
else
    echo "dev-cluster-config.yaml not found"
fi

# Remove dev-cluster from ArgoCD (if ArgoCD is accessible)
echo ""
echo "Attempting to remove dev-cluster from ArgoCD..."

# Switch to argocd cluster context first
if kubectl config get-contexts k3d-${ARGOCD_CLUSTER_NAME} &> /dev/null; then
    kubectl config use-context k3d-${ARGOCD_CLUSTER_NAME}
    
    # Check if ArgoCD is running
    if kubectl -n ${ARGOCD_NAMESPACE} get pods | grep -q "Running"; then
        # Try to remove cluster from ArgoCD
        if argocd cluster list | grep -q "${DEV_CLUSTER_NAME}"; then
            echo "Removing ${DEV_CLUSTER_NAME} from ArgoCD..."
            argocd cluster rm --server-name ${DEV_CLUSTER_NAME} 2>/dev/null || echo "Could not remove cluster from ArgoCD (may not exist)"
        else
            echo "Dev-cluster not found in ArgoCD"
        fi
    else
        echo "ArgoCD not running, skipping ArgoCD cleanup"
    fi
else
    echo "ArgoCD cluster context not found, skipping ArgoCD cleanup"
fi

echo ""
echo "Dev-cluster cleanup completed!"
echo "You can now recreate it with:"
echo "./01b_generate_dev_config.sh"
echo "./02b_create_dev_cluster.sh"