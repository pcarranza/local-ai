.PHONY: start stop clean prune
build:
	podman build -t localhost/ollama:latest-dev .

start:
	podman run \
		--detach \
		--replace \
		--pod local-ai \
		--name ollama \
		--group-add keep-groups \
		-e OLLAMA_MODELS=/workspace/.ollama/models \
		-e OLLAMA_VULKAN=1 \
		-e OLLAMA_HOST=127.0.0.1:11434 \
		-e OLLAMA_DEBUG=0 \
		--health-startup-cmd "curl http://localhost:11434/api/generate -d '{ \"model\": \"qwen3.5:2b\"}'" \
		--health-startup-timeout 60s \
		--health-cmd "curl http://localhost:11434/" \
		--health-timeout 2s \
		--health-retries 10 \
		--health-interval 30s \
		localhost/ollama:latest-dev

stop:
	podman stop ollama

clean: stop
	podman rm ollama

prune:
	podman image rm localhost/ollama:latest-dev
