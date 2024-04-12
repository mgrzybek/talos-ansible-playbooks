ifdef LIMIT ## Limit ansible hosts to manage
	LIMIT_OPTS=-l $(LIMIT)
else
	LIMIT_OPTS=
endif

ifdef VERBOSE ## Set ansible in verbose mode (bool)
	VERBOSE_OPTS=-vvv
endif

ANSIBLE_OPTS=-i ../inventory.ini $(LIMIT_OPTS) $(VERBOSE_OPTS)

ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

SIDERO_CONTROLLER_MANAGER_HOST_NETWORK=false
ifndef SIDERO_CONTROLLER_MANAGER_DEPLOYMENT_STRATEGY ## Sidero deployment strategy
	SIDERO_CONTROLLER_MANAGER_DEPLOYMENT_STRATEGY=Recreate
endif
ifndef SIDERO_CONTROLLER_MANAGER_API_ENDPOINT ## Sidero API endpoint
	SIDERO_CONTROLLER_MANAGER_API_ENDPOINT=192.168.1.150
endif
ifndef SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT ## Siderolink endpoint
	SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT=192.168.1.150
endif

##############################################################################
# Files to watch

../controlplane.yaml:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

../worker.yaml:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

../talosconfig:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

##############################################################################
# Create the cluster

.PHONY: bootstrap
bootstrap:
	$(ANSIBLE_PLAYBOOK) playbooks/bootstrap.yml

.PHONY: apply-conf
apply-conf:
	$(ANSIBLE_PLAYBOOK) playbooks/apply-conf.yml

.PHONY: health
health:
	$(ANSIBLE_PLAYBOOK) playbooks/health.yml

.PHONY: cluster-reset
cluster-reset: ## Reset the cluster (nodes are wiped, kubectl context removed)
	$(ANSIBLE_PLAYBOOK) playbooks/reset.yml
	rm -f ../talosconfig ../worker.yaml ../controlplane.yaml ../*.host.yaml

.PHONY: cluster-shutdown
cluster-shutdown: ## Stop the nodes but keep the current configuration
	$(ANSIBLE_PLAYBOOK) playbooks/shutdown.yml

.PHONY: cluster-cneate
cluster-create: ## Create a cluster
	@$(MAKE) ../controlplane.yaml
	@$(MAKE) apply-conf LIMIT=controlplane
	@$(MAKE) bootstrap
	@$(MAKE) apply-conf LIMIT=worker


##############################################################################
# LoadBalancer configuration
.PHONY: cilium-l2
cilium-l2: ## Deploy Cilium L2 CiliumLoadBalancerIPPool and CiliumL2AnnouncementPolicy
	$(ANSIBLE_PLAYBOOK) playbooks/cilium-l2.yml

##############################################################################
# Rook Ceph targets

.PHONY: rook-ceph-operator
rook-ceph-operator: ## Install Rook operator for Ceph
	kubectl apply -f manifests/rook.common.yaml
	kubectl patch namespace rook-ceph -p '{ "metadata": { "labels": { "pod-security.kubernetes.io/enforce": "privileged" } } }'
	kubectl apply -f manifests/rook.crds.yaml -f manifests/rook.operator.yaml
	kubectl -n rook-ceph wait deployment/rook-ceph-operator --for=condition=Available  --timeout=1h > /dev/null

.PHONY: rook-ceph-cluster
rook-ceph-cluster: rook-ceph-operator cilium-l2 ## Deploy a ceph cluster
	$(ANSIBLE_PLAYBOOK) playbooks/ceph-cluster.yml

##############################################################################
# Metal-as-a-Service targets

## Sidero

manifests/bootstrap.clusterctl.yaml:
	clusterctl generate provider --bootstrap talos > manifests/bootstrap.clusterctl.yaml

manifests/controlplane.clusterctl.yaml:
	clusterctl generate provider --control-plane talos > manifests/controlplane.clusterctl.yaml

manifests/infrastructure.clusterctl.yaml:
	clusterctl generate provider --infrastructure sidero > manifests/infrastructure.clusterctl.yaml

.PHONY: sidero-metal
sidero-metal: manifests/bootstrap.clusterctl.yaml manifests/controlplane.clusterctl.yaml manifests/infrastructure.clusterctl.yaml ## Install the sidero deployment stack
	$(ANSIBLE_PLAYBOOK) playbooks/sidero-metal.yml \
		-e api_endpoint_ipaddr=$(SIDERO_CONTROLLER_MANAGER_API_ENDPOINT) \
		-e siderolink_endpoint_ipaddr=$(SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT)


## Tinkerbell

/tmp/tink-charts:
	git clone https://github.com/tinkerbell/charts /tmp/tink-charts

.PHONY: tinkerbell
tinkerbell: cilium-l2 /tmp/tink-charts
	$(ANSIBLE_PLAYBOOK) playbooks/tinkerbell.yml

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
