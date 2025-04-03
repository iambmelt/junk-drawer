#!/bin/bash

# Locate the docker-compose.yml file in the current directory
COMPOSE_FILE="docker-compose.yml"

# Verify that the file exists
if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "[ERROR] No 'docker-compose.yml' file found in the current directory."
    exit 1
fi

# Extract the container name and image name from the compose file
CONTAINER_NAME=$(grep -Po '(?<=container_name:\s).*' "$COMPOSE_FILE" | head -1)
IMAGE_NAME=$(grep -Po '(?<=image:\s).*' "$COMPOSE_FILE" | head -1)

# Verify that we extracted both values
if [[ -z "$CONTAINER_NAME" ]]; then
    echo "[ERROR] Could not determine the container name from 'docker-compose.yml'."
    exit 1
fi

if [[ -z "$IMAGE_NAME" ]]; then
    echo "[ERROR] Could not determine the image name from 'docker-compose.yml'."
    exit 1
fi

echo "[INFO] Found container '$CONTAINER_NAME' using image '$IMAGE_NAME'."

# Check if the container exists
if ! docker inspect "$CONTAINER_NAME" &>/dev/null; then
    echo "[ERROR] No container named '$CONTAINER_NAME' is currently running."
    exit 1
fi

# Get current container details
CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME")
CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")
MOUNTED_VOLUMES=$(docker inspect --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}\n{{end}}' "$CONTAINER_NAME")

echo "[INFO] Current container details:"
echo "  - Container Name: $CONTAINER_NAME"
echo "  - Image: $CURRENT_IMAGE"
echo "  - IP Address: ${CONTAINER_IP:-N/A}"
echo "  - Mounted Volumes:"
echo -e "$MOUNTED_VOLUMES"

# Confirmation prompt
read -rp "Proceed with updating container '$CONTAINER_NAME' using image '$IMAGE_NAME'? (Y/n): " CONFIRM
CONFIRM=${CONFIRM:-Y}
if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; then
    echo "[INFO] Update canceled."
    exit 0
fi

echo "[INFO] Pulling latest image '$IMAGE_NAME'..."
if ! docker pull "$IMAGE_NAME"; then
    echo "[ERROR] Failed to pull latest image."
    exit 1
fi

echo "[INFO] Stopping container '$CONTAINER_NAME'..."
if ! docker stop "$CONTAINER_NAME"; then
    echo "[ERROR] Failed to stop container '$CONTAINER_NAME'."
    exit 1
fi

echo "[INFO] Removing container '$CONTAINER_NAME'..."
if ! docker rm "$CONTAINER_NAME"; then
    echo "[ERROR] Failed to remove container '$CONTAINER_NAME'."
    exit 1
fi

echo "[INFO] Starting container with docker-compose..."
if ! docker-compose up -d; then
    echo "[ERROR] Failed to start container with docker-compose."
    exit 1
fi

echo "[INFO] Checking container status..."
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "[SUCCESS] Container '$CONTAINER_NAME' is running."
else
    echo "[WARNING] Container '$CONTAINER_NAME' does not appear to be running. Please check manually."
fi

# Cleanup unused images
echo "[INFO] Cleaning up unused Docker images..."
docker image prune -f

echo "[SUCCESS] Update process completed."
