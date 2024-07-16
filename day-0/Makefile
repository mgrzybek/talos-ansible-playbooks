ifndef TALOS_FACTORY_URL ## Talos Factory URL (https://factory.talos.dev/image)
	TALOS_FACTORY_URL=https://factory.talos.dev
endif

ifndef TALOS_VERSION ## Talos version to use (using talosctl version by default)
	TALOS_VERSION=$(shell talosctl version 2>/dev/null | awk '/Tag/ {print $$NF}' | head -n1)
endif

ifdef VERBOSE ## Set ansible in verbose mode (bool)
	VERBOSE_OPTS=-vvv
endif

ANSIBLE_OPTS=-i ../inventory.ini $(VERBOSE_OPTS)
ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

CILIUM_VERSION=$(shell yq ".cilium.version"  ../group_vars/controlplane.yml)
DOCKER_REGISTRY_ENDPOINT=$(shell yq ".docker_registry_endpoint" ../group_vars/all.yml)

DRAWIO_BIN=draw.io
DRAWIO=$(DRAWIO_BIN) --export --embed-svg-images

WHICH=$(shell uname -s | fgrep -q Linux && echo "which" || echo "which -s")

architecture.drawio:
workflow.drawio:

schematic.json: ## Get schematic json data from the talos factory
	$(WHICH) curl
	$(WHICH) tee
	$(WHICH) talosctl
	curl -X POST --data-binary @bare-metal.yaml $(TALOS_FACTORY_URL)/schematics -o schematic.json

metal-amd64.iso: schematic.json ## Download amd64 iso from the talos factory
	$(WHICH) jq
	$(WHICH) wget
	$(WHICH) talosctl
	wget $(TALOS_FACTORY_URL)/image/$(shell cat schematic.json | jq -r ".id")/$(TALOS_VERSION)/metal-amd64.iso

metal-arm64.iso: schematic.json ## Download arm64 iso from the talos factory
	$(WHICH) jq
	$(WHICH) wget
	wget $(TALOS_FACTORY_URL)/image/$(shell cat schematic.json | jq -r ".id")/$(TALOS_VERSION)/metal-arm64.iso

architecture.svg: architecture.drawio ## Create architecture
	$(WHICH) $(DRAWIO_BIN)
	$(DRAWIO) --output architecture.svg architecture.drawio

workflow.svg: workflow.drawio ## Create workflow
	$(WHICH) $(DRAWIO_BIN)
	$(DRAWIO) --output workflow.svg workflow.drawio

.PHONY: clean
clean: ## Remove the downloaded artifacts
	rm -f *.iso
	rm -f schematic.json

.PHONY: requirements
requirements:
	ansible-galaxy install -r requirements.yml

.PHONY: libvirt
libvirt:
	sudo $(ANSIBLE_PLAYBOOK) playbooks/libvirt.yml

.PHONY: airgap-registry
airgap-registry: ## Create a local registry using docker
	$(WHICH) curl
	$(WHICH) docker
	$(WHICH) helm
	$(WHICH) talosctl

	@echo Checking cilium version…
	! test -z $(CILIUM_VERSION)
	echo $(CILIUM_VERSION) | fgrep -v null

	@echo Checking the registry…
	! test -z $(DOCKER_REGISTRY_ENDPOINT)
	echo $(DOCKER_REGISTRY_ENDPOINT) | fgrep -v null
	curl -s "$(DOCKER_REGISTRY_ENDPOINT)/v2/_catalog?pretty=true"

	@echo Pulling the images…
	for image in $(shell talosctl image default ; helm template cilium cilium/cilium --version $(CILIUM_VERSION) | awk '/ image:/ {gsub("\"","");gsub("@sha.+?","");print $$2}' | sort -u) ; do \
		docker pull $$image ; \
	done

	@echo Retagging the images…
	for image in $(shell talosctl image default ; helm template cilium cilium/cilium --version $(CILIUM_VERSION) | awk '/ image:/ {gsub("\"","");gsub("@sha.+?","");print $$2}' | sort -u) ; do \
		docker tag $$image `echo $$image | sed -E 's#^[^/]+/#$(DOCKER_REGISTRY_ENDPOINT)/#'`; \
	done

	@echo Pushing the images into the local registry…
	for image in $(shell talosctl image default ; helm template cilium cilium/cilium --version $(CILIUM_VERSION) | awk '/ image:/ {gsub("\"","");gsub("@sha.+?","");print $$2}' | sort -u) ; do \
		docker push `echo $$image | sed -E 's#^[^/]+/#$(DOCKER_REGISTRY_ENDPOINT)/#'`; \
	done

##############################################################################
# Help

.PHONY: help
help: ## This help message
	@echo Global variables
	@echo ================
	@awk \
		'$$1 ~ /^ifdef/ && $$3 ~ /##/ {gsub(/##/,"\t") ; gsub("ifdef ","") ; print $$0}' \
		Makefile \
	| expand -t35 \
	| sort
	@awk \
		'$$1 ~ /^ifndef/ && $$3 ~ /##/ {gsub(/##/,"\t") ; gsub("ifndef ","") ; print $$0}' \
		Makefile \
	| expand -t35 \
	| sort
	@echo

	@echo Targets
	@echo =======
	@awk -F: \
		'$$1 ~/^[a-z\$$\.\/_]/ && $$2~/##/ {gsub(/: .*?\s*##/, "\t");print $$0}' \
		Makefile \
	| expand -t35 \
	| sort
