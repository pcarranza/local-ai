.PHONE: build start enable disable stop debug
build:
	$(MAKE) -C ../ build
	mkdir -p ~/.config/containers/systemd 
	cp *.pod ~/.config/containers/systemd/ 
	cp *.container ~/.config/containers/systemd/

start:
	systemctl --user daemon-reload
	systemctl --user start local-ai-runner-pod.service ollama.service local-ai-agent.service

enable: start
	echo "Unlike regular systemd services, you cannot use systemctl enable on a Quadlet file. Quadlet automatically enables services with an [Install] section."

disable:
	echo "Unlike regular systemd services, you cannot use systemctl disable on a Quadlet file. Quadlet automatically enables services with an [Install] section."

stop:
	systemctl --user stop local-ai-runner-pod.service ollama.service local-ai-agent.service

debug:
	/usr/libexec/podman/quadlet -dryrun -user
