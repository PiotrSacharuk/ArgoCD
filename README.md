# ArgoCD Setup Project Structure

```
.
├── cluster-config.yaml         # k3d cluster configuration
├── 01_configure.sh             # Setup script for tools installation
├── 02_create_cluster.sh        # Script to create and verify the cluster
├── 03_install_argocd_svc.sh    # ArgoCD installation and setup script
├── 04_run_argocd_webui.sh      # Start ArgoCD Web UI (background)
├── 04b_stop_argocd_webui.sh    # Stop ArgoCD Web UI (optional)
└── README.md                   # This file
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
├── .env.example               # Environment variables template
├── cluster-config.yaml        # k3d cluster configuration (basic)
├── 01_configure.sh            # Setup script for tools installation
├── 01b_generate_dev_config.sh # Generate dev-cluster-config.yaml with dynamic IP
├── 02_create_cluster.sh       # Script to create and verify the cluster
├── 02b_create_dev_cluster.sh  # Create development cluster with dynamic config
├── 03_install_argocd_svc.sh   # ArgoCD installation and setup script
├── 04_run_argocd_webui.sh     # Start ArgoCD Web UI (background)
├── 04b_stop_argocd_webui.sh   # Stop ArgoCD Web UI (optional)
├── 06_setup_argocd_dev.sh     # Setup ArgoCD with dev-cluster
├── 08_cleanup_argocd_cluster.sh # Cleanup/reset main ArgoCD cluster
├── 08b_cleanup_dev_cluster.sh  # Cleanup/reset dev-cluster (optional)
└── README.md                  # This file
```

## Files Description

### cluster-config.yaml
k3d cluster configuration file that defines:
- 1 server node
- 2 agent nodes
- Simple cluster setup

### 01_configure.sh
Bash script that handles:
- Docker user group configuration for WSL
- kubectl installation (latest stable version)
- k3d installation
- Tool verification

### 01b_generate_dev_config.sh
Dynamic configuration generator that:
- Detects current IP address from eth0 interface
- Generates dev-cluster-config.yaml with TLS SAN
- Provides alternative cluster configuration for development

### 02_create_cluster.sh
Cluster creation script that:
- Creates the k3d cluster named "argocd-cluster"
- Verifies cluster nodes are running
- Displays kubeconfig information

### 02b_create_dev_cluster.sh
Development cluster creation script that:
- Creates k3d cluster named "dev-cluster"
- Uses dev-cluster-config.yaml (with dynamic IP/TLS SAN)
- Automatically updates kubeconfig with external IP
- Verifies cluster nodes and connection

### 03_install_argocd_svc.sh
ArgoCD installation script that:
- Creates argocd namespace
- Installs ArgoCD from official manifests
- Downloads and installs ArgoCD CLI tool
- Verifies deployment status and shows all resources

### 04_run_argocd_webui.sh
ArgoCD Web UI launcher with flexible modes:
- Sets up service access (NodePort)
- Displays admin password
- **Default**: Runs port-forward in background
- **Option -f**: Runs in foreground (blocks terminal)
- Checks for existing processes to avoid duplicates

### 04b_stop_argocd_webui.sh
ArgoCD Web UI stopper (optional) that:
- Finds all ArgoCD port-forward processes
- Safely terminates background processes
- Verifies successful shutdown

### 06_setup_argocd_dev.sh
ArgoCD development setup that:
- Switches to argocd-cluster context
- Adds dev-cluster to ArgoCD
- Provides admin password for login
- Lists existing projects, repos, and applications
- Guides through creating dev-argocd project

### 08_cleanup_argocd_cluster.sh
ArgoCD cluster cleanup script that:
- Stops ArgoCD WebUI port-forward processes
- Deletes k3d ArgoCD cluster completely
- Removes ArgoCD CLI configuration
- Shows remaining clusters and recreation instructions

### 08b_cleanup_dev_cluster.sh
Dev-cluster cleanup script (optional) that:
- Deletes k3d dev-cluster completely
- Removes generated dev-cluster-config.yaml
- Removes dev-cluster from ArgoCD (if accessible)
- Provides instructions for recreation

## Quick Start

1. **Setup environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Setup tools and environment:**
   ```bash
   chmod +x 01_configure.sh
   ./01_configure.sh
   ```

2. **Create k3d cluster:**
   ```bash
   chmod +x 02_create_cluster.sh
   ./02_create_cluster.sh
   ```

3. **Install ArgoCD:**
   ```bash
   chmod +x 03_install_argocd_svc.sh
   sudo ./03_install_argocd_svc.sh
   ```

4. **Start ArgoCD Web UI:**
   ```bash
   chmod +x 04_run_argocd_webui.sh
   ./04_run_argocd_webui.sh
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

## ArgoCD Web UI Management

After installation, manage the ArgoCD Web UI:

**Start ArgoCD Web UI:**
```bash
# Run in background (default - doesn't block terminal)
./04_run_argocd_webui.sh

# Run in foreground (blocks terminal, use Ctrl+C to stop)
./04_run_argocd_webui.sh -f
```

**Stop ArgoCD Web UI (optional):**
```bash
chmod +x 04b_stop_argocd_webui.sh
./04b_stop_argocd_webui.sh
```

**Access Details:**
- URL: https://localhost:8080
- Username: admin
- Password: (displayed by run script)

## Next Steps

After running the complete setup, you can proceed with:
- Configuring ArgoCD applications
- Setting up GitOps workflows
- Creating application manifests

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