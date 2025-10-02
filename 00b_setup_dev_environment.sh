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

echo "========================================="
echo "ArgoCD Dev Environment Setup Script"
echo "========================================="
echo "This will create dev cluster and integrate with ArgoCD"
echo ""

# Check if ArgoCD cluster exists
if ! k3d cluster list | grep -q "${ARGOCD_CLUSTER_NAME}"; then
    echo "Error: ArgoCD cluster not found!"
    echo "Please run ./00_setup_complete_environment.sh first"
    exit 1
fi

# Ask for confirmation
read -p "Do you want to proceed with dev environment setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 1
fi

echo ""
echo "Starting dev environment setup..."

# Step 1: Generate dev config
echo ""
echo "========================================="
echo "Step 1/3: Generating dev cluster config"
echo "========================================="
chmod +x ./01b_generate_dev_config.sh
./01b_generate_dev_config.sh
if [ $? -ne 0 ]; then
    echo "Error: Dev config generation failed"
    exit 1
fi

# Step 2: Create dev cluster
echo ""
echo "========================================="
echo "Step 2/3: Creating dev cluster"
echo "========================================="
chmod +x ./02b_create_dev_cluster.sh
./02b_create_dev_cluster.sh
if [ $? -ne 0 ]; then
    echo "Error: Dev cluster creation failed"
    exit 1
fi

# Step 3: Setup ArgoCD with dev cluster
echo ""
echo "========================================="
echo "Step 3/3: Integrating dev cluster with ArgoCD"
echo "========================================="

# Ensure ArgoCD cluster is running
kubectl config use-context k3d-${ARGOCD_CLUSTER_NAME}
echo "Checking if ArgoCD is accessible..."
if ! curl -k -s --connect-timeout 5 https://localhost:${ARGOCD_PORT} > /dev/null; then
    echo "Warning: ArgoCD may not be accessible. Ensure it's running with:"
    echo "  ./04_run_argocd_webui.sh"
    echo ""
fi

echo "Waiting 10 seconds for dev cluster to be ready..."
sleep 10

chmod +x ./06_setup_argocd_dev.sh
./06_setup_argocd_dev.sh
if [ $? -ne 0 ]; then
    echo "Warning: ArgoCD dev integration had issues, but dev cluster is ready"
fi

echo ""
echo "========================================="
echo "DEV ENVIRONMENT SETUP COMPLETED"
echo "========================================="
echo ""
echo "Your dev environment is ready:"
echo "• Dev Cluster: k3d-${DEV_CLUSTER_NAME}"
echo "• Integrated with ArgoCD: k3d-${ARGOCD_CLUSTER_NAME}"
echo "• ArgoCD WebUI: https://localhost:${ARGOCD_PORT}"
echo ""
echo "Next steps:"
echo "1. Open ArgoCD UI: https://localhost:${ARGOCD_PORT}"
echo "2. Create applications targeting dev-cluster"
echo "3. Enjoy GitOps workflows!"
echo ""
echo "Cleanup commands:"
echo "• Reset dev cluster: ./08b_cleanup_dev_cluster.sh"
echo "• Reset everything: ./08_cleanup_argocd_cluster.sh"