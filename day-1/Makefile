ifdef MAYASTOR
	MAYASTOR=true
else
	MAYASTOR=false
endif

ifdef LIMIT
	LIMIT_OPTS=-l $(LIMIT)
else
	LIMIT_OPTS=
endif

ANSIBLE_OPTS=-i ../inventory.ini \
	-e cluster_name=$(CLUSTER_NAME) \
	-e use_mayastor=$(MAYASTOR) \
	$(LIMIT_OPTS)

ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

MAYASTOR_NAMESPACE=$(shell yq ".metadata.name" manifests/mayastor.namespace.yaml)
OPENEBS_NAMESPACE=$(shell yq ".metadata.name" manifests/openebs.namespace.yaml)
TESTING_NAMESPACE=$(shell yq ".metadata.namespace" manifests/nginx-testing.resources.yaml | tail -n1)

##############################################################################
# Files to watch

../controlplane.yaml:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

../worker.yaml:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

../talosconfig:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

##############################################################################
# Talos targets

.PHONY: bootstrap
bootstrap:
	$(ANSIBLE_PLAYBOOK) playbooks/bootstrap.yml

.PHONY: apply
apply:
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
	@$(MAKE) apply
	@$(MAKE) bootstrap

##############################################################################
# OpenEBS targets

manifests/mayastor.resources.yaml: ## Create mayastor manifest using helm template
	@helm template mayastor mayastor/mayastor \
		-n $(MAYASTOR_NAMESPACE) \
		--version 2.5.0 \
		> manifests/mayastor.yaml

.PHONY: openebs-operator
openebs-operator: ## Install OpenEBS operator
	$(ANSIBLE_PLAYBOOK) playbooks/prepare-openebs.yml
	kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
	kubectl apply -f manifests/openebs.namespace.yaml

.PHONY: openebs-test-local-pvc
openebs-test-local-pvc: ## Test a local PVC using a nginx pod
	@kubectl apply -f manifests/nginx-testing.resources.yaml > /dev/null
	@kubectl -n $(TESTING_NAMESPACE) wait deployment/nginx-deployment --for=condition=Available > /dev/null
	@kubectl -n $(TESTING_NAMESPACE) exec $$(kubectl -n $(TESTING_NAMESPACE) get pods -o json | jq -r ".items[0].metadata.name") -- df -h  \
		| fgrep -q /var/lib/nginx && echo "OpenEBS host path provisioning is working"
	@kubectl delete -f manifests/nginx-testing.resources.yaml > /dev/null

.PHONY: openebs-mayastor
openebs-mayastor: manifests/mayastor.resources.yaml ## Install Mayastor CSI
	$(ANSIBLE_PLAYBOOK) playbooks/prepare-mayastor.yml
	kubectl apply -f manifests/mayastor.namespace.yaml
	kubectl -n $(MAYASTOR_NAMESPACE) apply -f manifests/mayastor.resources.yaml

##############################################################################
# Help

.PHONY: help
help: ## This help message
	@awk -F: \
		'/^([a-z\.-]+): *.* ## (.+)$$/ {gsub(/: .*?\s*##/, "\t");print}' \
		Makefile \
	| expand -t25 \
	| sort
