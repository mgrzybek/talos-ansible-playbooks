ifdef LIMIT ## Limit ansible hosts to manage
	LIMIT_OPTS=-l $(LIMIT)
else
	LIMIT_OPTS=
endif

ifdef VERBOSE ## Set ansible in verbose mode (bool)
	VERBOSE_OPTS=-vvv
endif

ANSIBLE_OPTS=-i ../inventory.ini \
	-e cluster_name=$(CLUSTER_NAME) \
	$(LIMIT_OPTS) $(VERBOSE_OPTS)

ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

KUBECTL_DELETE=kubectl delete --wait=true

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
	$(ANSIBLE_PLAYBOOK) playbooks/add-nodes.yml

.PHONY: upgrade-k8s
upgrade-k8s: ## Upgrade k8s to the given version (KUBERNETES_VERSION)
	$(ANSIBLE_PLAYBOOK) playbooks/upgrade-k8s.yml -e kubernetes_version=$(KUBERNETES_VERSION)

.PHONY: upgrade-cilium
upgrade-cilium: ## Upgrade cilium cni to the given vension
	which cilium
	$(ANSIBLE_PLAYBOOK) playbooks/upgrade-cilium.yml

.PHONY: remove-node
remove-node: ## Remove a node from the cluster (NODE_IP, NODE_NAME)
	@$(call check_defined NODE_IP)
	@$(call check_defined NODE_NAME)

	talosctl -n $(NODE_IP) -e $(NODE_IP) reset --talosconfig=../talosconfig
	kubectl remove node $(NODE_NAME)
	rm -f ../$(NODE_IP).host.yaml

##############################################################################
# Removing services

.PHONY: remove-rook-operator
remove-rook-ceph: ## Remove Rook operator for Ceph
	kubectl --namespace rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-remove-data"}}}'

	kubectl delete storageclasses ceph-block ceph-bucket ceph-filesystem

	kubectl --namespace rook-ceph delete cephblockpools ceph-blockpool
	kubectl --namespace rook-ceph delete cephobjectstore ceph-objectstore
	kubectl --namespace rook-ceph delete cephfilesystem ceph-filesystem
	kubectl --namespace rook-ceph delete cephcluster rook-ceph

	kubectl --namespace rook-ceph delete -f ../day-1/manifests/rook.cluster.yaml
	kubectl --namespace rook-ceph delete -f ../day-1/manifests/rook.operator.yaml
	kubectl --namespace rook-ceph delete -f ../day-1/manifests/rook.common.yaml
	kubectl --namespace rook-ceph delete -f ../day-1/manifests/rook.crds.yaml

.PHONY: remove-tinkerbell
remove-tinkerbell: ## Remove Tinkerbell
	kubectl delete ns tink-system --wait
	kubectl delete crds \
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
