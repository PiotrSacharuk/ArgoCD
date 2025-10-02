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

echo "Generating dev-cluster-config.yaml with dynamic IP..."

# Get the IP address from configured interface
IP=`ifconfig ${INTERFACE_NAME} | grep inet | grep -v inet6 | awk '{print $2}'`

if [ -z "$IP" ]; then
    echo "Error: Could not determine IP address from ${INTERFACE_NAME} interface"
    echo "Please check if ${INTERFACE_NAME} interface exists and has an IP assigned"
    exit 1
fi

echo "Detected IP address: $IP"

# Generate dev-cluster-config.yaml with the detected IP
cat > dev-cluster-config.yaml << EOF
apiVersion: k3d.io/v1alpha2
kind: Simple
options:
  k3s:
      extraServerArgs:
        - --tls-san=$IP
      extraAgentArgs: []
EOF

echo "Generated dev-cluster-config.yaml successfully"
echo "Configuration will use IP: $IP for TLS SAN"
echo ""
echo "File contents:"
cat dev-cluster-config.yaml