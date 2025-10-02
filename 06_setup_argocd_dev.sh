#!/bin/bash

echo "Setting up ArgoCD with dev-cluster configuration..."

# Switch to argocd-cluster context
echo "Switching to argocd-cluster context..."
kubectl config use-context k3d-argocd-cluster

# Check if ArgoCD is running
echo "Checking if ArgoCD is running..."
kubectl -n argocd get pods | grep Running | wc -l

# Get ArgoCD admin password
echo ""
echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_PASSWORD"

# Add dev-cluster to ArgoCD (if it exists)
echo ""
if kubectl config get-contexts k3d-dev-cluster &> /dev/null; then
    echo "Adding dev-cluster to ArgoCD..."
    argocd cluster add k3d-dev-cluster --name dev-cluster
    echo "Dev-cluster added successfully"
else
    echo "Warning: k3d-dev-cluster context not found. Create dev-cluster first with ./02b_create_dev_cluster.sh"
fi

# Login to ArgoCD
echo ""
echo "Logging into ArgoCD..."
echo "Please use username: admin"
echo "Password: $ARGOCD_PASSWORD"
argocd login localhost:8080

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
DEV_CLUSTER_SERVER=$(kubectl config view -o jsonpath='{.clusters[?(@.name=="k3d-dev-cluster")].cluster.server}')
echo ""
echo "Dev-cluster server address: $DEV_CLUSTER_SERVER"

# Create new project with main training repo
echo ""
echo "Creating new project 'dev-argocd'..."

MAIN_REPO="https://github.com/PiotrSacharuk/argocd-training-public-repo.git"

if [ ! -z "$DEV_CLUSTER_SERVER" ]; then
    echo "Using dev-cluster server: $DEV_CLUSTER_SERVER"
    echo "Using main training repository: $MAIN_REPO"

    argocd proj create dev-argocd \
        -d "$DEV_CLUSTER_SERVER,default" \
        -s "$MAIN_REPO"

    echo "Project 'dev-argocd' created successfully!"
else
    echo "Could not detect dev-cluster server address."
    echo "Manual command:"
    echo "argocd proj create dev-argocd -d <server-address>,default -s $MAIN_REPO"
fi

echo ""
echo "Setup completed. You can now create applications in ArgoCD."