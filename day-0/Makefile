TALOS_FACTORY_URL=https://factory.talos.dev/image
TALOS_VERSION=v1.6.2

DRAWIO=draw.io --export --embed-svg-images

architecture.drawio:
workflow.drawio:

schematic.json: ## Get schematic json data from the talos factory
	curl -X POST --data-binary @bare-metal.yaml $(TALOS_FACTORY_URL)/schematics | tee schematic.json

metal-amd64.iso: schematic.json ## Download amd64 iso from the talos factory
	wget $(TALOS_FACTORY_URL)/$(shell cat schematic.json | jq -r ".id")/$(TALOS_VERSION)/metal-amd64.iso 

metal-arm64.iso: schematic.json ## Download arm64 iso from the talos factory
	wget $(TALOS_FACTORY_URL)/$(shell cat schematic.json | jq -r ".id")/$(TALOS_VERSION)/metal-arm64.iso 

architecture.svg: architecture.drawio
	$(DRAWIO) --output architecture.svg architecture.drawio

workflow.svg: workflow.drawio
	$(DRAWIO) --output workflow.svg workflow.drawio

##############################################################################
# Help

.PHONY: help
help: ## This help message
	@echo Global variables
	@echo ================
	@awk \
		'$$1 ~ /^ifdef/ && $$3 ~ /##/ {gsub(/##/,"\t") ; gsub("ifdef ","") ; print $$0}' \
		Makefile \
	| expand -t50 \
	| sort
	@awk \
		'$$1 ~ /^ifndef/ && $$3 ~ /##/ {gsub(/##/,"\t") ; gsub("ifndef ","") ; print $$0}' \
		Makefile \
	| expand -t50 \
	| sort
	@echo

	@echo Targets
	@echo =======
	@awk -F: \
		'$$1 ~/^[a-z\$$\.\/_]/ && $$2~/##/ {gsub(/: .*?\s*##/, "\t");print $$0}' \
		Makefile \
	| expand -t35 \
	| sort
