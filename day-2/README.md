# Day-2 operations

## Synopsis

```console
$ make help
Global variables
================
LIMIT                          Limit ansible hosts to manage
VERBOSE                        Set ansible in verbose mode (bool)

Targets
=======
add-nodes                      Add new nodes to the cluster
cluster-reboot                 Reboot the cluster (one by one)
cluster-reset                  Reset the cluster (nodes are wiped, kubectl context removed)
cluster-shutdown               Stop the nodes but keep the current configuration
help                           This help message
remove-cert-manager            Remove Cert Manager
remove-nodes                   Remove nodes deleted from the inventory
remove-quickwit                Remove Quickwit
remove-rook-ceph               Remove Rook operator for Ceph
remove-tinkerbell              Remove Tinkerbell
upgrade-k8s                    Upgrade k8s to the given version (KUBERNETES_VERSION)
upgrade-talos                  Upgrade k8s to the given version (KUBERNETES_VERSION)
$
```

## Nodes

Adding a node:

```console
$ vim ../inventory.ini # Add some nodes into the inventory
$ make add-nodes
```

Remove nodes:

```console
$ vim ../inventory.ini # Remove some nodes
$ make remove-nodes
```

## Upgrades

Get the last version from GitHub and upgrade.

```console
$ export KUBERNETES_TAGS=https://api.github.com/repos/kubernetes/kubernetes/tags
$ export KUBERNETES_VERSION=$(curl -s $KUBERNETES_TAGS | jq -r ".[].name" | awk '!/alpha/ && !/beta/ && !/rc/' | head -n1)
$ make upgrade-k8s
```

## Deletions

Remove the middleware you want using their target:

```console
$ make remove-rook-ceph
$ make remove-tinkerbell
```
