ANSIBLE_OPTS=-i ../inventory.ini -e cluster_name=$(CLUSTER_NAME)
ANSIBLE_PLAYBOOK=ansible-playbook $(ANSIBLE_OPTS)

##############################################################################
# Files to watch

../controlplane.yaml:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

../worker.yaml:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

../talosconfig:
	$(ANSIBLE_PLAYBOOK) playbooks/gen-conf.yml

##############################################################################
# Actions

.PHONY: bootstrap
bootstrap:
	$(ANSIBLE_PLAYBOOK) playbooks/bootstrap.yml

.PHONY: apply
apply:
	$(ANSIBLE_PLAYBOOK) playbooks/apply-conf.yml

.PHONY: health
health:
	$(ANSIBLE_PLAYBOOK) playbooks/health.yml

.PHONY: reset
reset: ## Reset the cluster (nodes are wiped, kubectl context removed)
	$(ANSIBLE_PLAYBOOK) playbooks/reset.yml
	rm -f ../talosconfig ../worker.yaml ../controlplane.yaml

.PHONY: shutdown
shutdown: ## Stop the nodes but keep the current configuration
	$(ANSIBLE_PLAYBOOK) playbooks/shutdown.yml

.PHONY: openebs-operator
openebs-operator: ## Install OpenEBS operator
	kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
	kubectl label namespace openebs pod-security.kubernetes.io/enforce=privileged

.PHONY: openebs-test
openebs-test-local-pvc: ## Test a local PVC using a nginx pod
	@kubectl get ns test 2> /dev/null || kubectl create ns test > /dev/null
	@kubectl -n test apply -f manifests/nginx.yaml > /dev/null
	@kubectl -n test wait deployment/nginx-deployment --for=condition=Available > /dev/null
	@kubectl -n test exec $$(kubectl -n test get pods -o json | jq -r ".items[0].metadata.name") -- df -h  \
		| fgrep -q /var/lib/nginx && echo "OpenEBS host path provisioning is working"
	@kubectl delete ns test > /dev/null

.PHONY: create-cluster
create-cluster: ## Create a cluster
	@$(MAKE) ../controlplane.yaml
	@$(MAKE) apply
	@$(MAKE) bootstrap

##############################################################################
# Help

.PHONY: help
help: ## This help message
	@awk -F: \
		'/^([a-z\.-]+): *.* ## (.+)$$/ {gsub(/: .*?\s*##/, "\t");print}' \
		Makefile \
	| expand -t20 \
	| sort
