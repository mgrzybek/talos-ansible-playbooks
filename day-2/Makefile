ifdef LIMIT ## Limit ansible hosts to manage
	LIMIT_OPTS=-l $(LIMIT)
else
	LIMIT_OPTS=
endif

ifdef VERBOSE ## Set ansible in verbose mode (bool)
	VERBOSE_OPTS=-vvv
endif

ANSIBLE_OPTS=-i ../inventory.ini \
	$(LIMIT_OPTS) $(VERBOSE_OPTS)

ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

KUBECTL_DELETE=kubectl delete --wait=true

WHICH=$(shell uname -s | fgrep -q Linux && echo "which" || echo "which -s")

check_defined = \
	$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
	$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))

##############################################################################
# Files to watch

##############################################################################
# Cluster management

.PHONY: add-nodes
add-nodes: ## Add new nodes to the cluster
	test -f ../controlplane.yaml
	test -f ../worker.yaml
	test -f ../talosconfig
	$(WHICH) ansible-playbook
	$(ANSIBLE_PLAYBOOK) playbooks/add-nodes.yml

.PHONY: cluster-shutdown
cluster-shutdown: ## Stop the nodes but keep the current configuration
	@$(MAKE) -C ../day-1 cluster-shutdown

.PHONY: cluster-reset
cluster-reset: ## Reset the cluster (nodes are wiped, kubectl context removed)
	@$(MAKE) -C ../day-1 cluster-reset

.PHONY: upgrade-talos
upgrade-talos: ## Upgrade k8s to the given version (KUBERNETES_VERSION)
	$(WHICH) ansible-playbook
	$(ANSIBLE_PLAYBOOK) playbooks/upgrade-talos.yml

.PHONY: upgrade-k8s
upgrade-k8s: ## Upgrade k8s to the given version (KUBERNETES_VERSION)
	$(WHICH) ansible-playbook
	$(ANSIBLE_PLAYBOOK) playbooks/upgrade-k8s.yml -e kubernetes_version=$(KUBERNETES_VERSION)

.PHONY: upgrade-cilium
upgrade-cilium: ## Upgrade cilium cni to the given vension
	$(WHICH) cilium
	$(WHICH) ansible-playbook
	$(ANSIBLE_PLAYBOOK) playbooks/upgrade-cilium.yml

.PHONY: remove-nodes
remove-nodes: ## Remove nodes deleted from the inventory
	$(WHICH) ansible-playbook
	$(ANSIBLE_PLAYBOOK) playbooks/remove-nodes.yml

##############################################################################
# Removing services

.PHONY: remove-rook-operator
remove-rook-ceph: ## Remove Rook operator for Ceph
	kubectl --namespace rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-remove-data"}}}'

	$(KUBECTL_DELETE) storageclasses ceph-block ceph-bucket ceph-filesystem

	$(KUBECTL_DELETE) --namespace rook-ceph cephblockpools ceph-blockpool
	$(KUBECTL_DELETE) --namespace rook-ceph cephobjectstore ceph-objectstore
	$(KUBECTL_DELETE) --namespace rook-ceph cephfilesystem ceph-filesystem
	$(KUBECTL_DELETE) --namespace rook-ceph cephcluster rook-ceph

	$(KUBECTL_DELETE) --namespace rook-ceph -f ../day-1/manifests/rook.cluster.yaml
	$(KUBECTL_DELETE) --namespace rook-ceph -f ../day-1/manifests/rook.operator.yaml
	$(KUBECTL_DELETE) --namespace rook-ceph -f ../day-1/manifests/rook.common.yaml
	$(KUBECTL_DELETE) --namespace rook-ceph -f ../day-1/manifests/rook.crds.yaml

.PHONY: remove-tinkerbell
remove-tinkerbell: ## Remove Tinkerbell
	$(KUBECTL_DELETE) ns tink-system
	$(KUBECTL_DELETE) crds \
		hardware.tinkerbell.org \
		jobs.bmc.tinkerbell.org \
		machines.bmc.tinkerbell.org \
		tasks.bmc.tinkerbell.org \
		templates.tinkerbell.org \
		workflows.tinkerbell.org

##############################################################################
# Help

.PHONY: help
help: ## This help message
	@echo Global variables
	@echo ================
	@awk \
		'$$1 ~ /^ifdef/ && $$3 ~ /##/ {gsub(/##/,"\t") ; gsub("ifdef ","") ; print $$0}' \
		Makefile \
	| expand -t30 \
	| sort
	@awk \
		'$$1 ~ /^ifndef/ && $$3 ~ /##/ {gsub(/##/,"\t") ; gsub("ifndef ","") ; print $$0}' \
		Makefile \
	| expand -t30 \
	| sort
	@echo

	@echo Targets
	@echo =======
	@awk -F: \
		'/^([a-z0-9\.-]+): *.* ## (.+)$$/ {gsub(/: .*?\s*##/, "\t");print}' \
		Makefile \
	| expand -t30 \
	| sort
