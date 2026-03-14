.PHONY: start stop clean purge
build:
	podman build -t localhost/ai-agent:latest-dev .

start:
	podman run \
		--detach \
		--replace \
		--pod local-ai \
		--name ai-agent \
		--health-cmd "bash -c 'nc -zv localhost 3001 && nc -zv localhost 3000'" \
		--health-timeout 20s \
		--health-retries 10 \
		--health-interval 30s \
		localhost/ai-agent:latest-dev


stop:
	podman stop ai-agent

clean: stop
	podman rm ai-agent

purge:
	podman image rm localhost/ai-agent:latest-dev
