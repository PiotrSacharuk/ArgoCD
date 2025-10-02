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
echo "ArgoCD Main Environment Setup Script"
echo "========================================="
echo "This will create ArgoCD cluster and install ArgoCD"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with ArgoCD setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 1
fi

echo ""
echo "Starting ArgoCD main environment setup..."

# Step 1: Configure tools
echo ""
echo "========================================="
echo "Step 1/7: Configuring tools and environment"
echo "========================================="
if [ -f "./01_configure.sh" ]; then
    chmod +x ./01_configure.sh
    ./01_configure.sh
    if [ $? -ne 0 ]; then
        echo "Error: Tool configuration failed"
        exit 1
    fi
else
    echo "Skipping tool configuration (01_configure.sh not found)"
fi

# Step 2: Create ArgoCD cluster
echo ""
echo "========================================="
echo "Step 2/4: Creating ArgoCD cluster"
echo "========================================="
chmod +x ./02_create_cluster.sh
./02_create_cluster.sh
if [ $? -ne 0 ]; then
    echo "Error: ArgoCD cluster creation failed"
    exit 1
fi

# Wait for cluster to be ready and verify connection
echo "Waiting for cluster to be ready..."
sleep 5
kubectl cluster-info
if [ $? -ne 0 ]; then
    echo "Warning: Cluster connection issues detected, but continuing..."
fi

# Step 3: Install ArgoCD
echo ""
echo "========================================="
echo "Step 3/4: Installing ArgoCD"
echo "========================================="
chmod +x ./03_install_argocd_svc.sh
./03_install_argocd_svc.sh
if [ $? -ne 0 ]; then
    echo "Error: ArgoCD installation failed"
    exit 1
fi

# Wait for ArgoCD server to be ready
echo "Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Step 4: Start ArgoCD WebUI
echo ""
echo "========================================="
echo "Step 4/4: Starting ArgoCD WebUI"
echo "========================================="
chmod +x ./04_run_argocd_webui.sh
./04_run_argocd_webui.sh
if [ $? -ne 0 ]; then
    echo "Warning: ArgoCD WebUI start failed, but continuing..."
fi

echo ""
echo "========================================="
echo "ArgoCD SETUP COMPLETED"
echo "========================================="
echo ""
echo "Your ArgoCD main environment is ready:"
echo "• ArgoCD Cluster: k3d-${ARGOCD_CLUSTER_NAME}"
echo "• ArgoCD WebUI: https://localhost:${ARGOCD_PORT}"
echo ""
echo "Next steps:"
echo "1. Open browser: https://localhost:${ARGOCD_PORT}"
echo "2. Login with: admin / [password shown above]"
echo "3. Optionally setup dev cluster: ./00b_setup_dev_environment.sh"
echo ""
echo "Cleanup commands:"
echo "• Reset ArgoCD: ./08_cleanup_argocd_cluster.sh"