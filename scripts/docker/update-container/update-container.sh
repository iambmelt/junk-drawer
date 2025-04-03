#!/bin/bash

# ------------------------
# Docker Single Container Updater
# Supports: --verbose and --dry-run
# ------------------------

# Defaults
VERBOSE=false
DRY_RUN=false

# Argument parsing
for arg in "$@"; do
    case $arg in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "[ERROR] Unknown argument: $arg"
            echo "Usage: $0 [--verbose] [--dry-run]"
            exit 1
            ;;
    esac
done

log() {
    echo "[INFO] $1"
}

vlog() {
    if [ "$VERBOSE" = true ]; then
        echo "[VERBOSE] $1"
    fi
}

warn() {
    echo "[WARNING] $1"
}

error() {
    echo "[ERROR] $1"
    exit 1
}

# Locate the docker-compose.yml file
COMPOSE_FILE="docker-compose.yml"
if [[ ! -f "$COMPOSE_FILE" ]]; then
    error "No 'docker-compose.yml' file found in the current directory."
fi

# Extract container_name and image
CONTAINER_NAME=$(grep -Po '(?<=container_name:\s).*' "$COMPOSE_FILE" | head -1)
IMAGE_NAME=$(grep -Po '(?<=image:\s).*' "$COMPOSE_FILE" | head -1)

if [[ -z "$CONTAINER_NAME" ]]; then
    error "Could not determine the container name from 'docker-compose.yml'."
fi

if [[ -z "$IMAGE_NAME" ]]; then
    error "Could not determine the image name from 'docker-compose.yml'."
fi

log "Found container '$CONTAINER_NAME' using image '$IMAGE_NAME'."

if ! docker inspect "$CONTAINER_NAME" &>/dev/null; then
    error "No container named '$CONTAINER_NAME' is currently running."
fi

CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME")
CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")
MOUNTED_VOLUMES=$(docker inspect --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}\n{{end}}' "$CONTAINER_NAME")

log "Current container details:"
echo "  - Container Name: $CONTAINER_NAME"
echo "  - Image: $CURRENT_IMAGE"
echo "  - IP Address: ${CONTAINER_IP:-N/A}"
echo "  - Mounted Volumes:"
echo -e "$MOUNTED_VOLUMES"

read -rp "Proceed with updating container '$CONTAINER_NAME' using image '$IMAGE_NAME'? (Y/n): " CONFIRM
CONFIRM=${CONFIRM:-Y}
if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; then
    log "Update canceled."
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    log "Dry-run mode enabled. No changes will be made."
    exit 0
fi

log "Pulling latest image '$IMAGE_NAME'..."
docker pull "$IMAGE_NAME" || error "Failed to pull latest image."

log "Stopping container '$CONTAINER_NAME'..."
docker stop "$CONTAINER_NAME" || error "Failed to stop container."

log "Removing container '$CONTAINER_NAME'..."
docker rm "$CONTAINER_NAME" || error "Failed to remove container."

log "Starting container with docker-compose..."
docker-compose up -d || error "Failed to start container."

log "Checking container status..."
if docker ps | grep -q "$CONTAINER_NAME"; then
    log "Container '$CONTAINER_NAME' is running."
else
    warn "Container '$CONTAINER_NAME' does not appear to be running. Please check manually."
fi

log "Cleaning up unused Docker images..."
docker image prune -f

log "Update process completed."
