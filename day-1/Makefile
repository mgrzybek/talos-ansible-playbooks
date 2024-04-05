ifdef LIMIT ## Limit ansible hosts to manage
	LIMIT_OPTS=-l $(LIMIT)
else
	LIMIT_OPTS=
endif

ifdef VERBOSE
	VERBOSE_OPTS=-vvv
endif

ANSIBLE_OPTS=-i ../inventory.ini \
	-e cluster_name=$(CLUSTER_NAME) \
	$(LIMIT_OPTS) $(VERBOSE_OPTS)

ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

TESTING_NAMESPACE=$(shell yq ".metadata.namespace" manifests/nginx-testing-metallb.resources.yaml | tail -n1)

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
	rm -f ../talosconfig ../worker.yaml ../controlplane.yaml

.PHONY: cluster-shutdown
cluster-shutdown: ## Stop the nodes but keep the current configuration
	$(ANSIBLE_PLAYBOOK) playbooks/shutdown.yml

.PHONY: cluster-cneate
cluster-create: ## Create a cluster
	@$(MAKE) ../controlplane.yaml
	@$(MAKE) apply-conf
	@$(MAKE) bootstrap

##############################################################################
# Rook Ceph targets

.PHONY: rook-ceph-operator
rook-ceph-operator: ## Install Rook operator for Ceph
	kubectl apply -f manifests/rook.common.yaml
	kubectl patch namespace rook-ceph -p '{ "metadata": { "labels": { "pod-security.kubernetes.io/enforce": "privileged" } } }'
	kubectl apply -f manifests/rook.crds.yaml  -f manifests/rook.operator.yaml
	kubectl -n rook-ceph wait deployment/rook-ceph-operator --for=condition=Available > /dev/null

.PHONY: rook-ceph-cluster
rook-ceph-cluster: rook-ceph-operator
	kubectl apply -f manifests/rook.cluster.yaml

##############################################################################
# Metal-as-a-Service targets

manifests/bootstrap.clusterctl.yaml:
	clusterctl generate provider --bootstrap talos > manifests/bootstrap.clusterctl.yaml

manifests/controlplane.clusterctl.yaml:
	clusterctl generate provider --control-plane talos > manifests/controlplane.clusterctl.yaml

manifests/infrastructure.clusterctl.yaml:
	clusterctl generate provider --infrastructure sidero > manifests/infrastructure.clusterctl.yaml

.PHONY: sidero-metal
sidero-metal: manifests/bootstrap.clusterctl.yaml manifests/controlplane.clusterctl.yaml manifests/infrastructure.clusterctl.yaml ## Install the sidero deployment stack
	$(ANSIBLE_PLAYBOOK) playbooks/sidero-metal.yml \
		-e ipaddr_pool_name=$(METALLB_L2_IPADDR_POOL_NAME) \
		-e api_endpoint_ipaddr=$(SIDERO_CONTROLLER_MANAGER_API_ENDPOINT) \
		-e siderolink_endpoint_ipaddr=$(SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT)

##############################################################################
# Observability targets

manifests/opensearch-operator.yaml:
	helm template opensearch-operator opensearch-operator/opensearch-operator > manifests/opensearch-operator.yaml
	patch -p1 manifests/opensearch-operator.yaml < patchs/opensearch-operator.patch

.PHONY: opensearch
opensearch-operator: manifests/opensearch-operator.yaml
	kubectl apply -f manifests/opensearch.namespace.yaml
	kubectl apply -n $(OPENSEARCH_NAMESPACE) -f manifests/opensearch-operator.yaml

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
