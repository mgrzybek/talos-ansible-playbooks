ifndef TALOS_FACTORY_URL ## Talos Factory URL (https://factory.talos.dev/image)
	TALOS_FACTORY_URL=https://factory.talos.dev
endif

ifndef TALOS_VERSION ## Talos version to use (using talosctl version by default)
	TALOS_VERSION=$(shell talosctl version 2>/dev/null | awk '/Tag/ {print $$NF}' | head -n1)
endif

DRAWIO_BIN=draw.io
DRAWIO=$(DRAWIO_BIN) --export --embed-svg-images

WHICH=$(shell uname -s | fgrep -q Linux && echo "which" || echo "which -s")

architecture.drawio:
workflow.drawio:

schematic.json: ## Get schematic json data from the talos factory
	$(WHICH) curl
	$(WHICH) tee
	$(WHICH) talosctl
	curl -X POST --data-binary @bare-metal.yaml $(TALOS_FACTORY_URL)/schematics | tee schematic.json

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
