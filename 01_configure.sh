#!/bin/bash

## DOCKER USER GROUP CONFIGURATION

# This section assumes Docker Desktop for Windows is installed and integrated with WSL.
# It ensures the current user has permissions to run Docker commands.

echo "Checking Docker configuration..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

# Check if user is already in docker group
if groups "$USER" | grep -q docker; then
    echo "User $USER is already in docker group."
else
    echo "Adding user $USER to docker group..."
    # Add the current user to the docker group
    sudo usermod -aG docker "$USER"
    echo "User added to docker group. You may need to log out and back in for changes to take effect."
fi

# Test Docker access
if docker ps &> /dev/null; then
    echo "Docker is accessible without sudo."
else
    echo "Applying new group membership..."
    # Apply new group membership (requires re-login or new shell)
    newgrp docker
fi

echo ""
echo "=================================="

## KUBECTL INSTALLATION

echo "Checking kubectl installation..."

# Check if kubectl is already installed
if command -v kubectl &> /dev/null; then
    CURRENT_VERSION=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3 2>/dev/null || echo "unknown")
    echo "kubectl is already installed (version: $CURRENT_VERSION)"

    # Check if it's the latest version
    LATEST_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt 2>/dev/null)
    if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "" ]; then
        echo "Latest version available: $LATEST_VERSION"
        read -p "Do you want to update kubectl? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Updating kubectl..."
        else
            echo "Skipping kubectl update."
            kubectl version --client
            echo ""
            echo "=================================="
            exit 0
        fi
    else
        echo "kubectl is up to date."
        kubectl version --client
        echo ""
        echo "=================================="
        exit 0
    fi
else
    echo "kubectl not found. Installing kubectl..."
fi

# Install prerequisite packages for downloading kubectl
echo "Installing prerequisites..."
sudo apt update
sudo apt install -y curl

# Get the latest stable Kubernetes version number
echo "Getting latest kubectl version..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
echo "Latest version: $KUBECTL_VERSION"

# Download the kubectl binary for Linux AMD64
echo "Downloading kubectl..."
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"

# Make the binary executable
chmod +x ./kubectl

# Move the binary to a directory in your PATH
sudo mv ./kubectl /usr/local/bin/kubectl

# Verify the kubectl installation
echo "Verifying kubectl installation..."
kubectl version --client

echo ""
echo "=================================="

## K3D INSTALLATION

echo "Checking k3d installation..."

# Check if k3d is already installed
if command -v k3d &> /dev/null; then
    CURRENT_K3D_VERSION=$(k3d version | grep k3d | cut -d' ' -f3 2>/dev/null || echo "unknown")
    echo "k3d is already installed (version: $CURRENT_K3D_VERSION)"

    # Ask if user wants to update
    read -p "Do you want to reinstall/update k3d? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Reinstalling k3d..."
    else
        echo "Skipping k3d installation."
        k3d version
        echo ""
        echo "Setup completed successfully!"
        exit 0
    fi
else
    echo "k3d not found. Installing k3d..."
fi

# k3d is a wrapper to run k3s (Kubernetes) in Docker containers.
# Download and execute the k3d installation script.
echo "Downloading and installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Verify the k3d installation
echo "Verifying k3d installation..."
k3d version

echo ""
echo "Setup completed successfully!"
echo "All tools are now installed and ready to use."
