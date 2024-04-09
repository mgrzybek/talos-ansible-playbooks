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

KUBECTL_DELETE=kubectl delete --wait=true

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
upgrade-cilium: ## Upgrade cilium cni to the given vension (CILIUM_VERSION)
	which cilium
	$(ANSIBLE_PLAYBOOK) playbooks/upgrade-cilium.yml -e cilium_version=$(CILIUM_VERSION)

.PHONY: remove-node
remove-node: ## Remove a node from the cluster (NODE_IP, NODE_NAME)
	talosctl -n $(NODE_IP) -e $(NODE_IP) reset  --talosconfig=../talosconfig
	kubectl remove node $(NODE_NAME)
	rm -f ../$(NODE_IP).host.yaml

##############################################################################
# Removing services

.PHONY: destroy-rook-operator
destroy-rook-ceph: ## Remove Rook operator for Ceph
	kubectl --namespace rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
	kubectl delete storageclasses ceph-block ceph-bucket ceph-filesystem
	kubectl --namespace rook-ceph delete cephblockpools ceph-blockpool
	kubectl --namespace rook-ceph delete cephobjectstore ceph-objectstore
	kubectl --namespace rook-ceph delete cephfilesystem ceph-filesystem
	kubectl --namespace rook-ceph delete cephcluster rook-ceph
	helm --namespace rook-ceph uninstall rook-ceph-cluster
	helm --namespace rook-ceph uninstall rook-ceph
	kubectl delete crds cephblockpools.ceph.rook.io cephbucketnotifications.ceph.rook.io cephbuckettopics.ceph.rook.io \
		cephclients.ceph.rook.io cephclusters.ceph.rook.io cephfilesystemmirrors.ceph.rook.io \
		cephfilesystems.ceph.rook.io cephfilesystemsubvolumegroups.ceph.rook.io \
		cephnfses.ceph.rook.io cephobjectrealms.ceph.rook.io cephobjectstores.ceph.rook.io \
		cephobjectstoreusers.ceph.rook.io cephobjectzonegroups.ceph.rook.io cephobjectzones.ceph.rook.io \
		cephrbdmirrors.ceph.rook.io objectbucketclaims.objectbucket.io objectbuckets.objectbucket.io

##############################################################################
# Help

.PHONY: help
help: ## This help message
	@awk -F: \
		'/^([a-z0-9\.-]+): *.* ## (.+)$$/ {gsub(/: .*?\s*##/, "\t");print}' \
		Makefile \
	| expand -t30 \
	| sort
