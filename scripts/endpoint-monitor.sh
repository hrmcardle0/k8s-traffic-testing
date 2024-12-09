#!/bin/bash

# Variables
NAMESPACE="default"         # Change to your namespace
SERVICE_NAME="nginx"   # Change to your service name
POD_NAME="nginx"           # Change to the pod you want to delete

# Record the current timestamp
start_time=$(gdate +%s%3N)
echo "Start time: $(gdate +"%Y-%m-%d %H:%M:%S.%3N")"

# Delete the Pod

# Monitor endpoints until the Pod is removed
while true; do
  if ! kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.subsets[].addresses[*].ip}' | grep -q "$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.podIP}')"; then
    end_time=$(gdate +%s%3N)
    echo "Pod endpoint removed at: $(gdate +"%Y-%m-%d %H:%M:%S.%3N")"
    elapsed=$((end_time - start_time))
    echo "Time taken to remove endpoint: ${elapsed} ms"
    break
  fi
done
