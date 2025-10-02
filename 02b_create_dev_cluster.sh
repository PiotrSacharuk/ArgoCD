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

echo "Creating k3d development cluster..."

# Check if dev-cluster-config.yaml exists
if [ ! -f "dev-cluster-config.yaml" ]; then
    echo "Error: dev-cluster-config.yaml not found"
    echo "Run ./01b_generate_dev_config.sh first to generate the configuration"
    exit 1
fi

echo "Using configuration from dev-cluster-config.yaml"

# Create the k3d cluster with dev configuration
k3d cluster create ${DEV_CLUSTER_NAME} --config dev-cluster-config.yaml

# Wait for cluster to be ready
echo ""
echo "Waiting for cluster to be ready..."
sleep 10

# Verify cluster is working with default config first
echo "Testing cluster connectivity..."
kubectl get nodes

# Get the IP address and port for kubeconfig update
IP=`ifconfig ${INTERFACE_NAME} | grep inet | grep -v inet6 | awk '{print $2}'`
K3D_PORT=$(docker ps | grep "k3d-${DEV_CLUSTER_NAME}-serverlb" | grep -o "0.0.0.0:[0-9]*->6443" | cut -d: -f2 | cut -d- -f1)

if [ ! -z "$IP" ] && [ ! -z "$K3D_PORT" ]; then
    echo ""
    echo "Updating kubeconfig with external IP: $IP:$K3D_PORT"

    # Update server URL in kubeconfig for dev-cluster
    kubectl config set-cluster k3d-${DEV_CLUSTER_NAME} --server="https://$IP:$K3D_PORT"

    echo "Updated k3d-${DEV_CLUSTER_NAME} server URL to: https://$IP:$K3D_PORT"
else
    echo "Warning: Could not detect IP ($IP) or port ($K3D_PORT), kubeconfig not updated"
fi

# Verify cluster nodes are running with new config
echo ""
echo "Verifying cluster nodes with external IP..."
kubectl get nodes

# Display cluster information
echo ""
echo "Cluster information:"
kubectl cluster-info

# Display kubeconfig information
echo ""
echo "Kubeconfig context:"
kubectl config current-context

echo ""
echo "Development cluster '${DEV_CLUSTER_NAME}' created successfully"