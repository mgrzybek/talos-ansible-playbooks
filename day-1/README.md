# Day-1 operations

## Configuration

You should select the right disk to install the system. By default `/dev/vda` is used. This value can be changed in [all.yaml](./patchs/all.yaml).

## Bootstrap

```console
$ export CLUSTER_NAME=my-cluster # Choose cluster name
$ make cluster-create
```

## Deploy the desired storage layer

```console
$ make openebs-operator # Deploy OpenEBS operator
$ make openebs-test-local-pvc # Test local PVC using OpenEBS
```

```console
$ make openebs-mayastor # Deploy Mayastor resources
```
