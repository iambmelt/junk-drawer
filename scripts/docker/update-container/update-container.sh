#!/bin/bash
set -euo pipefail

# Logging functions for better readability.
log_info()    { echo "[INFO] $1"; }
log_warning() { echo "[WARNING] $1"; }
log_error()   { echo "[ERROR] $1"; }

# ------------------------------------------------------------------------------
# Display Help Message
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat <<EOF
Usage: $0 [directory] [--update-all|--prompt-each]

Description:
  This script updates Docker containers defined in a docker-compose.yml file. It performs
  the following steps for each service defined in the compose file:
    1. Checks if the specified directory (or the current directory by default) contains a docker-compose.yml file.
    2. Lists all services along with details of their running containers (if available).
    3. Pulls the latest image for each service.
    4. Stops and removes the service's container (if it is currently running).
    5. Recreates the container using docker-compose.
    6. Optionally prompts before updating each service if the '--prompt-each' flag is used.
    7. Finally, prompts before cleaning up unused Docker images and networks.

Options:
  [directory]       Directory containing the docker-compose.yml file (defaults to current directory).
  --update-all      Update all services automatically. (This is the default if no flag is provided.)
  --prompt-each     Prompt for confirmation before updating each individual service.
  --help            Display this help message.
EOF
    exit 0
fi

# ------------------------------------------------------------------------------
# Initialize variables.
# UPDATE_MODE can be "all" (default) or "prompt"
UPDATE_MODE=""
TARGET_DIR=""

# Process arguments.
# The first non-flag argument is assumed to be the target directory.
for arg in "$@"; do
    case "$arg" in
        --update-all)
            if [[ -n "$UPDATE_MODE" && "$UPDATE_MODE" != "all" ]]; then
                log_error "Conflicting update flags provided. Choose only one of --update-all or --prompt-each."
                exit 1
            fi
            UPDATE_MODE="all"
            ;;
        --prompt-each)
            if [[ -n "$UPDATE_MODE" && "$UPDATE_MODE" != "prompt" ]]; then
                log_error "Conflicting update flags provided. Choose only one of --update-all or --prompt-each."
                exit 1
            fi
            UPDATE_MODE="prompt"
            ;;
        *)
            # Assume non-flag argument to be the target directory if not already set.
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$arg"
            else
                log_warning "Extra argument '$arg' provided. Only the first non-flag argument (target directory) will be used."
            fi
            ;;
    esac
done

# Set default values if not provided.
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="."
fi

if [ -z "$UPDATE_MODE" ]; then
    UPDATE_MODE="all"
fi

log_info "Target directory set to '$TARGET_DIR'."
log_info "Update mode: ${UPDATE_MODE}."

# ------------------------------------------------------------------------------
# Validate target directory and docker-compose file.
if [ ! -d "$TARGET_DIR" ]; then
    log_error "Directory '$TARGET_DIR' does not exist."
    exit 1
fi

COMPOSE_FILE="$TARGET_DIR/docker-compose.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "No 'docker-compose.yml' file found in the directory '$TARGET_DIR'."
    exit 1
fi

# Change to the target directory.
cd "$TARGET_DIR"

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
# Retrieve list of services from the docker-compose configuration.
SERVICES=$($COMPOSE_CMD config --services)
if [ -z "$SERVICES" ]; then
    log_error "No services found in docker-compose.yml."
    exit 1
fi

log_info "Services defined in '$COMPOSE_FILE':"
for service in $SERVICES; do
    echo "  - $service"
done

# If using update-all mode, prompt once for confirmation.
if [ "$UPDATE_MODE" = "all" ]; then
    read -rp "Proceed with updating ALL services listed above? (Y/n): " CONFIRM_ALL
    CONFIRM_ALL=${CONFIRM_ALL:-Y}
    if [[ ! "$CONFIRM_ALL" =~ ^[Yy]$ ]]; then
        log_info "Update canceled by user."
        exit 0
    fi
fi

# ------------------------------------------------------------------------------
# Update Process for Each Service.
for service in $SERVICES; do
    echo "----------------------------------------"
    log_info "Processing service '$service'..."

    # Check if a container for the service is running.
    container_id=$($COMPOSE_CMD ps -q "$service" || true)
    if [ -n "$container_id" ]; then
        # Retrieve and display container details.
        IMAGE=$(docker inspect --format='{{.Config.Image}}' "$container_id")
        IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")
        VOLUMES=$(docker inspect --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}\n{{end}}' "$container_id")
        log_info "Service '$service' running container details:"
        echo "  - Container ID: $container_id"
        echo "  - Image: $IMAGE"
        echo "  - IP Address: ${IP:-N/A}"
        echo "  - Mounted Volumes:"
        echo -e "$VOLUMES"
    else
        log_warning "No running container found for service '$service'. It may be updated and started anew."
    fi

    # In prompt-each mode, ask for individual confirmation.
    if [ "$UPDATE_MODE" = "prompt" ]; then
        read -rp "Proceed with updating service '$service'? (Y/n): " CONFIRM_SERVICE
        CONFIRM_SERVICE=${CONFIRM_SERVICE:-Y}
        if [[ ! "$CONFIRM_SERVICE" =~ ^[Yy]$ ]]; then
            log_info "Skipping update for service '$service'."
            continue
        fi
    fi

    # Pull the latest image for the service.
    log_info "Pulling latest image for service '$service'..."
    if ! $COMPOSE_CMD pull "$service"; then
        log_error "Failed to pull the latest image for service '$service'."
        exit 1
    fi

    # If container is running, stop and remove it.
    if [ -n "$container_id" ]; then
        log_info "Stopping container for service '$service'..."
        if ! $COMPOSE_CMD stop "$service"; then
            log_error "Failed to stop container for service '$service'."
            exit 1
        fi

        log_info "Removing container for service '$service'..."
        if ! $COMPOSE_CMD rm -f "$service"; then
            log_error "Failed to remove container for service '$service'."
            exit 1
        fi
    fi

    # Recreate (start) the container.
    log_info "Starting (or recreating) container for service '$service'..."
    if ! $COMPOSE_CMD up -d "$service"; then
        log_error "Failed to start container for service '$service'."
        exit 1
    fi

    # Check container status.
    if $COMPOSE_CMD ps -q "$service" | grep -q .; then
        log_info "Service '$service' updated and is now running."
    else
        log_warning "Service '$service' does not appear to be running. Please check manually."
    fi
done

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

# ------------------------------------------------------------------------------
# Prompt user before cleaning up unused Docker networks.
read -rp "Clean up unused Docker networks? (Y/n): " NET_PRUNE_CONFIRM
NET_PRUNE_CONFIRM=${NET_PRUNE_CONFIRM:-Y}
if [[ "$NET_PRUNE_CONFIRM" =~ ^[Yy]$ ]]; then
    log_info "Cleaning up unused Docker networks..."
    if ! docker network prune -f; then
        log_warning "Docker network prune encountered an issue."
    fi
else
    log_info "Skipping cleanup of unused Docker networks."
fi

log_info "Update process completed."
