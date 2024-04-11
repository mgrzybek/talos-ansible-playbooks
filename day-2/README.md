# Day-2 operations

## Adding nodes

```console
$ vim ../inventory.ini # Add some nodes into the inventory
$ make add-nodes
```

## Upgrades

```console
$ export KUBERNETES_VERSION="x.xx.x"
$ make upgrade-k8s
```
