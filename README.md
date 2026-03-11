# ollama-opencode-openchamber-on-vulkan-amd

## Project Overview

`local-ai` is a self-contained, single-pod deployment that bundles together:

1. **Ollama** - an open-source LLM runtime.  It is started with a *pre-warm* command that loads a model (default: `qwen3.5:9b`) and keeps the process alive for a day.
2. **OpenCode** - a lightweight agent framework that lets you create and orchestrate LLM agents.
3. **OpenChamber** - a UI that sits on top of OpenCode, giving a visual interface for your agents.

All three services run inside a single Podman pod so you can start the whole stack with a single command. The images are built from the Dockerfiles under `ollama/` and `openchamber/` and can be rebuilt locally.

The repo contains a small Makefile that hides all the plumbing:

- `make build` - builds the two images.
- `make run` - creates a Podman pod named `local-ai` and launches the images in that pod.
- `make stop` - stops the containers.
- `make clean` - removes the images, containers and pod.

The pod exposes the following ports to the host:

| Host Port | Service | Note |
|-----------|---------|------|
| **11434** | Ollama API | `Ollama` listening on `localhost:11434` inside the pod.
| **3000** | OpenCode UI | UI for managing agents.
| **3001** | OpenChamber UI | UI for visualising agents inside OpenChamber.

The pod also mounts your local configuration directories (`~/.ollama`, `~/.config/opencode`, `~/.config/openchamber`) so all data and models persist between restarts.

A sample configuration file for both opencode and openchamber is provided inside `agent/config-sample` to save time figuring out how to set it up, just copy the folders inside `~/.config`.  It will also be necessary to create a ~/.opencode folder that will store the chat sessions in between pod restarts.

Because the host has an **AMD Radeon 890M Graphics** GPU the images are built from `docker.io/rocm/dev-ubuntu-24.04:7.2-complete` and use Vulkan to drive the GPU.  The required devices are passed into the pod with the `--device /dev/kfd --device /dev/dri` options.

This has been tested and used at length on top of a Beelink SER9 PRO AMD Pro Ryzen™ AI 9 HX

## Prerequisites

- **Podman** - The entire workflow is Podman based.  No Docker is required.
- A machine with an AMD GPU that exposes the Vulkan device nodes (`/dev/kfd`, `/dev/dri`) (I'm using ubuntu linux, but I guess any other can work).
- A user with the render group assigned `sudo usermod -aG render $USER`
- Sufficient disk space to pull the base image and store the compiled images.

## Quick Start

```bash
# Build images locally (required)
make build

# Run the pod and all services
make run

# The services are now reachable (also from outside of the machine):
#   * Ollama API  - http://localhost:11434
#   * OpenCode UI - http://localhost:3000
#   * OpenChamber UI - http://localhost:3001
```

### On your first run

You will need to launch ollama to download some models
```bash
# Get a bash inside the ollama running container
podman exec -it ollama /bin/bash

# Pull the models you want to use
ollama pull gpt-oss:20b

ollama pull qwen3.5:2b

ollama pull qwen3.5:9b
```

When you no longer need it:

```bash
make stop   # stop the containers
make clean  # delete containers & the pod
make prune  # delete images
```

## Environment Variables

These variables are passed to the containers by the Makefile.  You can also set them yourself if you are building or running the images directly.

| Variable | Default / Source | Purpose |
|---|---|---|
| `OLLAMA_VULKAN` | `1` | Enables Vulkan GPU acceleration in Ollama.
| `OLLAMA_DEBUG` | `0` | Verbosity level for Ollama's internal logging - use 1 or 2 to see more output.
| `OLLAMA_KEEP_ALIVE` | `-1` | Keeps the Ollama model loaded forever for faster replies (no unloading).
| `PRELOAD_MODEL` | `qwen3.5:9b` | Model to load on startup; the Dockerfile pulls `qwen3.5:9b` from the registry.
| `OLLAMA_MODELS` | `/root/.ollama/models` | Directory within the container that holds models (`~/.ollama` on the host).
| `OLLAMA_HOST` | `127.0.0.1:11434` | Bind address for the Ollama API inside the pod.
| `OPENCHAMBER_DATA_DIR` | `/root/.openchamber` | Persistent data directory for OpenChamber (`~/.config/openchamber` on the host).
| `OPENCODE_CONFIG_DIR` | `/root/.config/opencode/` | Configuration directory for the OpenCode CLI (`~/.config/opencode` on the host).

If you wish to override any of these values when running the container manually, simply prefix your `podman run` call with `-e VAR=value`.

## Hardware and GPU Notes

The images are built on the `rocm/dev-ubuntu-24.04:7.2-complete` base which contains ROCm drivers for AMD GPUs.  The `Ollama` image declares the environment flag `OLLAMA_VULKAN=1` which tells Ollama to use Vulkan for acceleration.  The host passes the device nodes `/dev/kfd` and `/dev/dri` into the pod, providing the GPU to the container.

Typical AMD GPUs (e.g., the 890M `RADV GFX1150`) work fine with this setup and do not trigger the stability issues that sometimes occur with older versions of the drivers, or with direct rocm driver access (trust me, I tested it) - it also don't crash your graphics card randomly.

## Quotas & Cleanup

The pod is lightweight, but the model cache in `~/.ollama/models` can grow large - a few Gigs.  The Makefile cleans up containers and images with `make clean`, but doesn't prune the model cache.  To free space:

```bash
rm -rf ~/.ollama/models/*
```

## Advanced Usage

If you prefer a systemd-based approach, the `quadlet/` directory contains Podman-Quadlet files that will let you install the pod as a user-service and have it start on boot.

`make run` is the quickest path, but you can also:

```bash
# Manual pod creation (shows how the Makefile works under the hood)
podman pod create \
    --replace \
    --name local-ai-runner \
    --security-opt label=type:container_runtime_t \
    --device /dev/kfd \
    --device /dev/dri \
    --publish 11434:11434 \
    --publish 3000:3000 \
    --publish 3001:3001 \
    --volume $HOME/.ollama:/root/.ollama \
    --volume $HOME/.config/opencode:/root/.config/opencode \
    --volume $HOME/.config/openchamber:/root/.config/openchamber \
    --volume $HOME/src:/root/workspace

podman run --detach --replace --pod local-ai-runner --name ollama localhost/ollama:latest-dev
podman run --detach --replace --pod local-ai-runner --name openchamber localhost/openchamber:latest-dev
```

Feel free to tweak port mappings or environment variables to suit your environment.

## Contributing & License

This repository is open source.  Feel free to open issues or pull requests.  It is licensed under the MIT license.

---

For detailed build logs or troubleshooting, raise log level, or output the container log with `podman logs <container>` (which can be raised by adding `--log-level debug` to the run command, and then consult the output of the `make run` command and the health-check URLs exposed by the containers at `/api/generate` and `/` for Ollama, and `/` for OpenCode / OpenChamber, different parts fail in different ways.

To know if your AMD card is being recognised inside the container, grep for `AMD` or `amdgpu` in the ollama container.

In my case I see this:
```log
time=XXX-Z level=INFO source=types.go:42 msg="inference compute" id=00000000-c500-0000-0000-000000000000 filter_id="" library=Vulkan compute=0.0 name=Vulkan0 description="AMD Radeon 890M Graphics (RADV GFX1150)" libdirs=ollama,vulkan driver=0.0 pci_id=0000:c5:00.0 type=iGPU total="33.2 GiB" available="32.3 GiB"
```
