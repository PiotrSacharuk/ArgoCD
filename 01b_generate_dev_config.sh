#!/bin/bash

echo "Generating dev-cluster-config.yaml with dynamic IP..."

# Get the IP address from eth0 interface
IP=`ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}'`

if [ -z "$IP" ]; then
    echo "Error: Could not determine IP address from eth0 interface"
    echo "Please check if eth0 interface exists and has an IP assigned"
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