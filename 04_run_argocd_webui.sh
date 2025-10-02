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

NAMESPACE=${ARGOCD_NAMESPACE}
ARGOCD_SERVER=argocd-server

# Check for -f flag (foreground mode)
FOREGROUND=false
if [ "$1" = "-f" ]; then
    FOREGROUND=true
fi

echo "Setting up ArgoCD Web UI access..."

# Ensure ArgoCD server is ready
echo "Checking if ArgoCD server is ready..."
if ! kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=argocd-server --field-selector=status.phase=Running 2>/dev/null | grep -q argocd-server; then
    echo "Warning: ArgoCD server may not be fully ready yet."
    echo "If port-forward fails, please wait a few minutes for ArgoCD to start completely."
    echo ""
fi

# Change service type to NodePort for easier access
kubectl patch svc ${ARGOCD_SERVER} -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'

# Get the admin password
echo "ArgoCD Admin Password:"
kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
echo ""

# Check if port-forward is already running
PID=$(pgrep -f "kubectl port-forward.*argocd-server")
if [ ! -z "$PID" ]; then
    echo "Port-forward is already running (PID: $PID)"
    echo "ArgoCD UI is available at: https://localhost:8080"
    exit 0
fi

if [ "$FOREGROUND" = true ]; then
    # Run in foreground mode
    echo "Starting port-forward in foreground mode..."
    echo "ArgoCD will be available at: https://localhost:8080"
    echo "Username: admin"
    echo "Password: (shown above)"
    echo ""
    echo "Press Ctrl+C to stop the port-forward and exit"
    echo "----------------------------------------"

    # Start port-forward (this will block until Ctrl+C)
    kubectl port-forward svc/${ARGOCD_SERVER} -n ${NAMESPACE} ${ARGOCD_PORT}:443
else
    # Run in background mode (default)
    echo "Starting port-forward in background..."
    kubectl port-forward svc/${ARGOCD_SERVER} -n ${NAMESPACE} ${ARGOCD_PORT}:443 > /dev/null 2>&1 &
    PORT_FORWARD_PID=$!

    # Wait a moment for port-forward to establish
    sleep 3

    # Check if port-forward started successfully
    if kill -0 $PORT_FORWARD_PID 2>/dev/null; then
        echo "Port-forward started successfully (PID: $PORT_FORWARD_PID)"
        echo "ArgoCD UI is now available at: https://localhost:${ARGOCD_PORT}"
        echo "Username: admin"
        echo "Password: (shown above)"
        echo ""
        echo "To stop the port-forward, run: ./04b_stop_argocd_webui.sh"
        echo "Or manually: kill $PORT_FORWARD_PID"
    else
        echo "Failed to start port-forward"
        exit 1
    fi
fi
