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

## Deploy the deployment stack

```console
$ export SIDERO_CONTROLLER_MANAGER_HOST_NETWORK=false # We use MetalLB
$ export SIDERO_CONTROLLER_MANAGER_DEPLOYMENT_STRATEGY=Recreate
$ export SIDERO_CONTROLLER_MANAGER_API_ENDPOINT= # MetalLB floating IP for Sidero API
$ export SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT= # MetalLB floating IP for Siredolinks’s Wireguard

$ make sidero-metal # Deploy sidero metal
```