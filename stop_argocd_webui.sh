#!/bin/bash

echo "Stopping ArgoCD Web UI..."

# Find all kubectl port-forward processes for argocd-server
PIDS=$(pgrep -f "kubectl port-forward.*argocd-server")

if [ -z "$PIDS" ]; then
    echo "No ArgoCD port-forward processes found running."
    exit 0
fi

echo "Found ArgoCD port-forward processes with PIDs: $PIDS"

# Kill the processes
for PID in $PIDS; do
    if kill $PID 2>/dev/null; then
        echo "Stopped process $PID"
    else
        echo "Failed to stop process $PID (may have already stopped)"
    fi
done

# Wait a moment and verify
sleep 2

# Check if any processes are still running
REMAINING=$(pgrep -f "kubectl port-forward.*argocd-server")
if [ -z "$REMAINING" ]; then
    echo "All ArgoCD port-forward processes stopped successfully"
    echo "ArgoCD Web UI is no longer accessible at https://localhost:8080"
else
    echo "Some processes may still be running: $REMAINING"
    echo "You can try: sudo kill -9 $REMAINING"
fi