# ArgoCD Setup Pr## Project Structure

```
.
├── cluster-config.yaml    # k3d cluster configuration
├── configure.sh          # Setup script for tools installation
├── create_cluster.sh     # Script to create and verify the cluster
├── install_argocd_svc.sh # ArgoCD installation and setup script
└── README.md            # This file
```is project provides configuration and setup scripts for ArgoCD deployment on a Kubernetes cluster using k3d.

## Overview

This repository contains:
- Configuration for creating a local Kubernetes cluster using k3d
- Installation scripts for required tools (kubectl, k3d)
- Setup procedures for ArgoCD deployment

## Prerequisites

- Docker Desktop (for Windows with WSL integration)
- Linux environment (WSL2 recommended on Windows)
- Internet connection for downloading tools and images

## Project Structure

```
.
├── cluster-config.yaml    # k3d cluster configuration
├── configure.sh           # Setup script for tools installation
├── create_cluster.sh      # Script to create and verify the cluster
└── README.md              # This file
```

## Files Description

### cluster-config.yaml
k3d cluster configuration file that defines:
- 1 server node
- 2 agent nodes
- Simple cluster setup

### configure.sh
Bash script that handles:
- Docker user group configuration for WSL
- kubectl installation (latest stable version)
- k3d installation
- Tool verification

### create_cluster.sh
Cluster creation script that:
- Creates the k3d cluster named "argocd-cluster"
- Verifies cluster nodes are running
- Displays kubeconfig information

### install_argocd_svc.sh
ArgoCD installation script that:
- Creates argocd namespace
- Installs ArgoCD from official manifests
- Downloads and installs ArgoCD CLI tool
- Verifies deployment status and shows all resources

## Quick Start

1. **Make the script executable:**
   ```bash
   chmod +x configure.sh
   ```

2. **Run the configuration script:**
   ```bash
   ./configure.sh
   ```

3. **Make the cluster creation script executable:**
   ```bash
   chmod +x create_cluster.sh
   ```

4. **Create the k3d cluster:**
   ```bash
   ./create_cluster.sh
   ```

5. **Install ArgoCD:**
   ```bash
   chmod +x install_argocd_svc.sh
   sudo ./install_argocd_svc.sh
   ```

6. **Verify cluster and ArgoCD are running:**
   ```bash
   kubectl cluster-info
   kubectl -n argocd get all
   ```

## What the Setup Does

### Docker Configuration
- Adds current user to docker group
- Enables Docker commands without sudo

### Tool Installation
- **kubectl**: Kubernetes command-line tool for cluster management
- **k3d**: Lightweight Kubernetes distribution runner in Docker

### Cluster Creation
- Creates a local Kubernetes cluster with 3 nodes total
- Provides isolated environment for ArgoCD testing and development

## Next Steps

After running the complete setup, you can proceed with:
- Accessing ArgoCD UI (port-forward or ingress setup)
- Getting ArgoCD admin password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- Configuring ArgoCD applications
- Setting up GitOps workflows

## Troubleshooting

### Docker Permission Issues
If you encounter Docker permission errors, try:
```bash
sudo usermod -aG docker $USER
newgrp docker
```
Or restart your terminal session.

### kubectl Connection Issues
Ensure k3d cluster is running:
```bash
k3d cluster list
k3d cluster start <cluster-name>
```

### Tool Version Verification
Check installed versions:
```bash
kubectl version --client
k3d --version
docker --version
```

## Notes

- This setup is designed for development and testing environments
- For production deployments, consider additional security configurations
- The cluster runs locally and will be destroyed when Docker containers are stopped

## Contributing

Feel free to submit issues and enhancement requests for improving this setup configuration.