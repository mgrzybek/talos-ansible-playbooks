ifdef LIMIT ## Limit ansible hosts to manage
	LIMIT_OPTS=-l $(LIMIT)
else
	LIMIT_OPTS=
endif

ANSIBLE_OPTS=-i ../inventory.ini \
	-e cluster_name=$(CLUSTER_NAME) \
	$(LIMIT_OPTS)

ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

MAYASTOR_NAMESPACE=$(shell yq ".metadata.name" manifests/mayastor.namespace.yaml)
OPENEBS_NAMESPACE=$(shell yq ".metadata.name" manifests/openebs.namespace.yaml)
TESTING_NAMESPACE=$(shell yq ".metadata.namespace" manifests/nginx-testing.resources.yaml | tail -n1)

ifndef SIDERO_CONTROLLER_MANAGER_HOST_NETWORK ## Bind Sidero endpoint using the host net
	SIDERO_CONTROLLER_MANAGER_HOST_NETWORK=false
endif
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
# Metal-as-a-Service targets

.PHONY: dhcp-service
dhcp-service: ## Install the dhcp deployment

.PHONY: sidero-metal
sidero-metal: ## Install the sidero deployment stack
	clusterctl init -b talos -c talos -i sidero

.PHONY: metallb
metallb: ## Deploy metallb
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml

.PHONY: metallb-test
metallb-test: ## Test Metal LB layer2 IP pool using a nginx pod
	@kubectl apply -f manifests/nginx-testing.resources.yaml > /dev/null
	@kubectl -n $(TESTING_NAMESPACE) wait deployment/nginx-deployment --for=condition=Available > /dev/null
	@curl http://$$(kubectl -n testing get svc -o json | jq -r ".items[0].status.loadBalancer.ingress[0].ip"):8080 \
		| fgrep -q "Welcome to nginx" && echo "MeltalLB L2 stack is working"
	@kubectl delete -f manifests/nginx-testing.resources.yaml > /dev/null

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