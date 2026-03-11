# User Quadlet configuration for local-ai

The repository now contains a complete quadlet setup that will create a *pod* named **local-ai** and deploy two containers - **ollama** and **ai-agent**. The setup will automatically start on user session live through systemd.

## What is quadlet?

Quadlet is Podman's declarative configuration system. Instead of writing `podman run` commands you create simple `.container`, `.service`, `.pod`, and `.volume` files in `~/.config/containers/systemd/`. Systemd then manages the containers as ordinary units.

### System requirements

You must be running podman 5 or later, this method will not work on podman 4.9 because it doesn't support pod quadlets yet.

Refer to this conversation for how to do it in Ubuntu LTS (noble): https://github.com/containers/podman/discussions/25582

Be sure to include crun in apt preferences as there is a dependency on a newer version for it too.

## Getting started

Follow the initial instructions from the parent [README.md](../README.md) file, once you have the images built, the config files in the right places, and you can run the tools, copy the `.container` and `.pod` files to `${HOME}/.config/containers/systemd` and then:

```bash
# Reload systemd
systemctl --user daemon-reload

# launch the pod
systemctl --user start local-ai-pod

# launch ollama
systemctl --user start ollama.service

# launch the agent
systemctl --user start ai-agent.service
```