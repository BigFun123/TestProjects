# HelloCompose - Docker Compose C# Console Application

A simple C# console application demonstrating Docker Compose usage with convenient command scripts.

## Prerequisites

- Docker Desktop installed and running
- .NET 8.0 SDK (optional, only needed for local development without Docker)

## Project Structure

```
HelloCompose/
├── Program.cs              # Main console application
├── HelloCompose.csproj     # .NET project file
├── Dockerfile              # Multi-stage Docker build configuration
├── docker-compose.yml      # Docker Compose orchestration file
├── README.md               # This file
└── *.cmd                   # Helper command scripts
```

## Application Overview

The console application outputs a heartbeat message every 5 seconds, demonstrating a long-running containerized service. It's useful for testing Docker Compose workflows and container lifecycle management.

## Command Files

### compose-build.cmd
**Purpose:** Build the Docker image without starting the container.

**Usage:** Double-click or run from command line.

**What it does:**
- Builds the Docker image using the Dockerfile
- Does not start the container
- Useful when you only want to verify the build process

### compose-up.cmd
**Purpose:** Build and start the application in detached mode.

**Usage:** Double-click or run from command line.

**What it does:**
- Builds the Docker image (if not already built or if changes detected)
- Starts the container in the background (detached mode)
- Container will restart automatically unless stopped manually
- Shows success/failure message

**After running:** Use `compose-logs.cmd` to view the output.

### compose-start.cmd
**Purpose:** Start the application without building (uses existing image).

**Usage:** Double-click or run from command line.

**What it does:**
- Starts the container using the existing Docker image
- Does NOT build or rebuild the image
- Useful when the image is already built and you just want to start the container
- Faster than `compose-up.cmd` since it skips the build step

### compose-down.cmd
**Purpose:** Stop and remove the running containers.

**Usage:** Double-click or run from command line.

**What it does:**
- Stops the running container(s)
- Removes the container(s)
- Keeps the Docker image intact
- Network and volumes are removed if not used by other containers

### compose-rebuild.cmd
**Purpose:** Force a complete rebuild without using cached layers.

**Usage:** Double-click or run from command line.

**What it does:**
- Rebuilds the Docker image from scratch (no cache)
- Starts the container in detached mode
- Use this when you make code changes and want to ensure a fresh build

### compose-logs.cmd
**Purpose:** View real-time logs from the running container.

**Usage:** Double-click or run from command line.

**What it does:**
- Shows live log output from the container
- Follows the log stream (similar to `tail -f`)
- Press `Ctrl+C` to stop viewing logs (container continues running)

### clean.cmd
**Purpose:** Complete cleanup of all Docker resources.

**Usage:** Double-click or run from command line.

**What it does:**
- Stops and removes containers
- Removes the `hellocompose:latest` image
- Prunes dangling images
- Frees up disk space

## Quick Start

1. **First time setup:**
   ```
   compose-up.cmd
   ```

2. **View the output:**
   ```
   compose-logs.cmd
   ```

3. **Stop the application:**
   ```
   compose-down.cmd
   ```

4. **After making code changes:**
   ```
   compose-rebuild.cmd
   compose-logs.cmd
   ```

5. **Complete cleanup:**
   ```
   clean.cmd
   ```

## Docker Compose Configuration

The `docker-compose.yml` file configures:
- **Service name:** `hellocompose`
- **Container name:** `hellocompose-app`
- **Image name:** `hellocompose:latest`
- **Restart policy:** `unless-stopped` (auto-restart on failure)
- **Environment:** Production mode

## Dockerfile Details

The Dockerfile uses a **multi-stage build** approach:
1. **Build stage:** Uses .NET 8.0 SDK to restore dependencies and publish the app
2. **Runtime stage:** Uses smaller .NET 8.0 runtime image for the final container

This approach keeps the final image size small by excluding build tools.

## Troubleshooting

**Container won't start:**
- Ensure Docker Desktop is running
- Check logs with `compose-logs.cmd`
- Try a clean rebuild: `clean.cmd` then `compose-up.cmd`

**Changes not reflected:**
- Use `compose-rebuild.cmd` to force a fresh build without cache

**Port conflicts:**
- This app doesn't expose ports, but if you add port mappings and get conflicts, stop other containers using those ports

**View running containers:**
```bash
docker ps
```

**Check Docker images:**
```bash
docker images | findstr hellocompose
```

## Customization

To modify the application behavior, edit [Program.cs](Program.cs) and run `compose-rebuild.cmd` to apply changes.

To change container configuration, edit [docker-compose.yml](docker-compose.yml) and run `compose-up.cmd`.
