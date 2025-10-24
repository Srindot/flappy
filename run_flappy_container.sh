#!/bin/bash

# ---------------------------------
# Run Purdue Flappy environment container
# Mount a local directory into /workspace
# ---------------------------------

# Exit on error
set -e

# Check Docker availability
if ! command -v docker &> /dev/null; then
    echo "Error: Docker not installed or available in PATH."
    exit 1
fi

# Take first argument as local directory (default to current path)
LOCAL_DIR=${1:-$(pwd)}

# Validate directory existence
if [ ! -d "$LOCAL_DIR" ]; then
    echo "Error: $LOCAL_DIR is not a valid directory."
    exit 1
fi

# Container name
CONTAINER_NAME="flappy_dev"

# Environment configuration
ENV_VARS=(
    "-e DISPLAY=$DISPLAY"
    "-e OMP_NUM_THREADS=4"
    "-e PYTHONUNBUFFERED=1"
)

# Run the container
echo "Starting container '$CONTAINER_NAME'..."
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    --network host \
    -v "$LOCAL_DIR":/workspace \
    "${ENV_VARS[@]}" \
    flappy-env:latest \
    /bin/bash

# Note:
# To reattach in VS Code, use “Dev Containers: Attach to Running Container”
