#!/bin/bash
set -euo pipefail

# Logging functions for better readability.
log_info()    { echo "[INFO] $1"; }
log_warning() { echo "[WARNING] $1"; }
log_error()   { echo "[ERROR] $1"; }

# ------------------------------------------------------------------------------
# Display Help Message
if [[ "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [directory]"
    echo
    echo "Description:"
    echo "  This script updates a Docker container defined in a docker-compose.yml file."
    echo "  It performs the following steps:"
    echo "    1. Checks if the specified directory (or current directory by default) contains a"
    echo "       docker-compose.yml file."
    echo "    2. Extracts the container name and image name from the docker-compose file using"
    echo "       flexible pattern matching (allowing minor formatting variations)."
    echo "    3. Verifies that the container is currently running by filtering 'docker ps' output."
    echo "    4. Pulls the latest version of the image."
    echo "    5. Stops and removes the running container."
    echo "    6. Recreates the container using docker-compose."
    echo "    7. Prompts before cleaning up unused Docker images."
    echo
    echo "Options:"
    echo "  [directory]  Directory containing the docker-compose.yml file (defaults to current directory)."
    echo "  --help       Display this help message."
    exit 0
fi

# ------------------------------------------------------------------------------
# Validate positional arguments: Only one expected.
if [ "$#" -gt 1 ]; then
    log_warning "Extra arguments provided. Only the first argument (target directory) will be used."
fi

# Determine the target directory.
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    log_error "Directory '$TARGET_DIR' does not exist."
    exit 1
fi

COMPOSE_FILE="$TARGET_DIR/docker-compose.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "No 'docker-compose.yml' file found in the directory '$TARGET_DIR'."
    exit 1
fi

# ------------------------------------------------------------------------------
# Pre-check for docker-compose command.
if command -v docker-compose &>/dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &>/dev/null; then
    COMPOSE_CMD="docker compose"
else
    log_error "Neither 'docker-compose' nor 'docker compose' command is available."
    exit 1
fi

# ------------------------------------------------------------------------------
# Extract container name and image name using flexible patterns.
# Using grep with sed to account for extra spaces and case variations.
CONTAINER_NAME=$(grep -i "container_name:" "$COMPOSE_FILE" | sed -E 's/.*container_name:[[:space:]]*//I' | head -1)
IMAGE_NAME=$(grep -i "image:" "$COMPOSE_FILE" | sed -E 's/.*image:[[:space:]]*//I' | head -1)

if [ -z "$CONTAINER_NAME" ]; then
    log_error "Could not determine the container name from '$COMPOSE_FILE'."
    exit 1
fi

if [ -z "$IMAGE_NAME" ]; then
    log_error "Could not determine the image name from '$COMPOSE_FILE'."
    exit 1
fi

log_info "Found container '$CONTAINER_NAME' using image '$IMAGE_NAME'."

# ------------------------------------------------------------------------------
# Verify that the container is running using docker ps.
if ! docker ps --filter "name=^/${CONTAINER_NAME}$" --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_error "No running container named '$CONTAINER_NAME' was found."
    exit 1
fi

# Retrieve current container details.
CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME")
CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")
MOUNTED_VOLUMES=$(docker inspect --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}\n{{end}}' "$CONTAINER_NAME")

log_info "Current container details:"
echo "  - Container Name: $CONTAINER_NAME"
echo "  - Image: $CURRENT_IMAGE"
echo "  - IP Address: ${CONTAINER_IP:-N/A}"
echo "  - Mounted Volumes:"
echo -e "$MOUNTED_VOLUMES"

# ------------------------------------------------------------------------------
# Prompt the user to confirm updating the container.
read -rp "Proceed with updating container '$CONTAINER_NAME' using image '$IMAGE_NAME'? (Y/n): " CONFIRM
CONFIRM=${CONFIRM:-Y}
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    log_info "Update canceled by user."
    exit 0
fi

# ------------------------------------------------------------------------------
# Update Process
log_info "Pulling latest image '$IMAGE_NAME'..."
if ! docker pull "$IMAGE_NAME"; then
    log_error "Failed to pull the latest image for '$IMAGE_NAME'."
    exit 1
fi

log_info "Stopping container '$CONTAINER_NAME'..."
if ! docker stop "$CONTAINER_NAME"; then
    log_error "Failed to stop container '$CONTAINER_NAME'."
    exit 1
fi

log_info "Removing container '$CONTAINER_NAME'..."
if ! docker rm "$CONTAINER_NAME"; then
    log_error "Failed to remove container '$CONTAINER_NAME'."
    exit 1
fi

log_info "Starting container with $COMPOSE_CMD..."
if ! $COMPOSE_CMD -f "$COMPOSE_FILE" up -d; then
    log_error "Failed to start container using $COMPOSE_CMD."
    exit 1
fi

# ------------------------------------------------------------------------------
# Check container status.
log_info "Checking container status..."
if docker ps --filter "name=^/${CONTAINER_NAME}$" --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_info "Container '$CONTAINER_NAME' is running."
else
    log_warning "Container '$CONTAINER_NAME' does not appear to be running. Please check manually."
fi

# ------------------------------------------------------------------------------
# Prompt user before cleaning up unused Docker images.
read -rp "Clean up unused Docker images? (Y/n): " PRUNE_CONFIRM
PRUNE_CONFIRM=${PRUNE_CONFIRM:-Y}
if [[ "$PRUNE_CONFIRM" =~ ^[Yy]$ ]]; then
    log_info "Cleaning up unused Docker images..."
    if ! docker image prune -f; then
        log_warning "Docker image prune encountered an issue."
    fi
else
    log_info "Skipping cleanup of unused Docker images."
fi

log_info "Update process completed."
