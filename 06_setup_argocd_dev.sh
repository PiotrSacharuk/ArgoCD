#!/bin/bash

# Load environment variables
if [ -f ".env" ]; then
    source .env
    echo "Loaded environment variables from .env"
else
    echo "Error: .env file not found"
    echo "Please copy .env.example to .env and configure it:"
    echo "cp .env.example .env"
    exit 1
fi

echo "Setting up ArgoCD with dev-cluster configuration..."

# Switch to argocd-cluster context
echo "Switching to ${ARGOCD_CLUSTER_NAME} context..."
kubectl config use-context k3d-${ARGOCD_CLUSTER_NAME}

# Check if ArgoCD is running
echo "Checking if ArgoCD is running in namespace ${ARGOCD_NAMESPACE}..."
kubectl -n ${ARGOCD_NAMESPACE} get pods | grep Running | wc -l

# Get ArgoCD admin password
echo ""
echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n ${ARGOCD_NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_PASSWORD"

# Add dev-cluster to ArgoCD (if it exists)
echo ""
if kubectl config get-contexts k3d-${DEV_CLUSTER_NAME} &> /dev/null; then
    echo "Adding ${DEV_CLUSTER_NAME} to ArgoCD..."
    argocd cluster add k3d-${DEV_CLUSTER_NAME} --name ${DEV_CLUSTER_NAME}
    echo "Dev-cluster added successfully"
else
    echo "Warning: k3d-${DEV_CLUSTER_NAME} context not found. Create dev-cluster first with ./02b_create_dev_cluster.sh"
fi

# Login to ArgoCD
echo ""
echo "Logging into ArgoCD..."
echo "Please use username: ${ARGOCD_USERNAME}"
echo "Password: $ARGOCD_PASSWORD"
argocd login localhost:${ARGOCD_PORT}

# Display current ArgoCD status
echo ""
echo "Current ArgoCD status:"
echo "Projects:"
argocd proj list
echo ""
echo "Repositories:"
argocd repo list
echo ""
echo "Applications:"
argocd app list
echo ""
echo "Clusters:"
argocd cluster list

# Try to get dev-cluster server address
DEV_CLUSTER_SERVER=$(kubectl config view -o jsonpath='{.clusters[?(@.name=="k3d-'${DEV_CLUSTER_NAME}'")].cluster.server}')
echo ""
echo "Dev-cluster server address: $DEV_CLUSTER_SERVER"

# Create new project with main training repo
echo ""
echo "Creating new project '${PROJECT_NAME}'..."

if [ ! -z "$DEV_CLUSTER_SERVER" ]; then
    echo "Using dev-cluster server: $DEV_CLUSTER_SERVER"
    echo "Using main training repository: $MAIN_REPO_URL"

    argocd proj create ${PROJECT_NAME} \
        -d "$DEV_CLUSTER_SERVER,${DEFAULT_NAMESPACE}" \
        -s "$MAIN_REPO_URL"

    echo "Project '${PROJECT_NAME}' created successfully!"
else
    echo "Could not detect dev-cluster server address."
    echo "Manual command:"
    echo "argocd proj create ${PROJECT_NAME} -d <server-address>,${DEFAULT_NAMESPACE} -s ${MAIN_REPO_URL}"
fi

echo ""
echo "Setup completed. You can now create applications in ArgoCD."