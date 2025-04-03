# Docker Single Container Update Script

This script performs a safe and repeatable update for **single-container** `docker-compose.yml` projects.

It will:
- Detect the container name and image automatically.
- Pull the latest image.
- Stop, remove, and recreate the container.
- Clean up unused Docker images.
- Preserve your volumes and data automatically.

---

## Features

- ✅ Automatic container and image detection
- ✅ Optional `--verbose` mode for more detailed output
- ✅ Optional `--dry-run` mode to preview actions without making changes
- ✅ Confirmation prompt before performing any update
- ✅ Clear `[INFO]`, `[WARNING]`, and `[ERROR]` logs for easy reading
- ✅ Safe to use over SSH and in minimal terminals

---

## Requirements

- Bash
- Docker
- `docker-compose` (hyphenated legacy version)
- A `docker-compose.yml` file defining **exactly one** service in the same (or provided) directory

---

## Usage

### Basic update

```bash
./update-container.sh
```

or

```bash
./update-container.sh [directory]
```

### Verbose mode

```bash
./update-container.sh --verbose
```

### Dry-run mode

```bash
./update-container.sh --dry-run
```

### Both

```bash
./update-container.sh --verbose --dry-run
```

---

## Notes

- This script will only operate on the **first** `container_name` and `image` found in the `docker-compose.yml` file.
- Your data will be preserved as long as it is stored in volumes or bind mounts defined in your compose file.

---

## Installation

1. Place the script in the directory with your `docker-compose.yml`.
2. Make it executable:
   ```bash
   chmod +x update-container.sh
   ```
3. Run it using one of the usage options above.

---

## Disclaimer

This script is provided *as-is*, without warranty of any kind. Use it at your own risk. Review the code and understand its behavior before running it on production systems.

---
