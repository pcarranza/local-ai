# System Quadlet configuration for local-ai

The repository now contains a complete quadlet setup that will create a *pod* named **local-ai** and deploy two containers - **ollama** and **ai-agent**. The setup will automatically start on system start through systemd.

## What is quadlet?

Quadlet is Podman's declarative configuration system. Instead of writing `podman run` commands you create simple `.container`, `.service`, `.pod`, and `.volume` files in `/etc/containers/systemd/`. Systemd then manages the containers as ordinary units.

### System requirements

You must be running podman 5 or later, this method will not work on podman 4.9 because it doesn't support pod quadlets yet.

Refer to this conversation for how to do it in Ubuntu LTS (noble): https://github.com/containers/podman/discussions/25582

Be sure to include crun in apt preferences as there is a dependency on a newer version for it too.

## Getting started

Follow the initial instructions from the parent [README.md](../README.md) file, once you have the images built for the root user (be sure to `sudo make build`), the config files in the right places, and you can manually launch the pod and containers, copy the `.container` and `.pod` files to `/etc/containers/systemd`, edit ai-agent.container and replace `<user>` for your user, and the `UID` and `GID` and then:

```bash
# Reload systemd
systemctl daemon-reload

# launch the pod
systemctl start local-ai-pod

# launch ollama
systemctl start ollama.service

# launch the agent
systemctl start ai-agent.service
```