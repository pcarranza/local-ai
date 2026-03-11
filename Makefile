.PHONY: start stop clean
build:
	$(MAKE) -C ollama build
	$(MAKE) -C ai-agent build

start:
	podman pod create \
		--replace \
		--name local-ai \
		--security-opt label=type:container_runtime_t \
		--device /dev/kfd \
		--device /dev/dri \
		--publish 11434:11434 \
		--publish 3000:3000 \
		--publish 3001:3001 \
		--userns keep-id:uid=$(shell id -u),gid=$(shell id -g) \
		--volume ${HOME}/workspace:/workspace \
		--volume ${HOME}/.ollama:/workspace/.ollama \
		--volume ${HOME}/.opencode:/workspace/.local/share/opencode \
		--volume ${HOME}/.config/opencode:/workspace/.config/opencode \
		--volume ${HOME}/.config/openchamber:/workspace/.config/openchamber
	$(MAKE) -C ollama start
	$(MAKE) -C ai-agent start

stop:
	$(MAKE) -C ollama stop
	$(MAKE) -C ai-agent stop

clean:
	$(MAKE) -C ollama clean
	$(MAKE) -C ai-agent clean
	podman pod rm local-ai

