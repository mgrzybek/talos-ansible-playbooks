# Day-1 operations

## Synopsis

```console
$ make help
Global variables
================
LIMIT                               Limit ansible hosts to manage
VERBOSE                             Set ansible in verbose mode (bool)

Targets
=======
cilium-l2                           Deploy Cilium L2 CiliumLoadBalancerIPPool and CiliumL2AnnouncementPolicy
cluster-create                      Create a cluster
cluster-reset                       Reset the cluster (nodes are wiped, kubectl context removed)
cluster-shutdown                    Stop the nodes but keep the current configuration
help                                This help message
rook-ceph-cluster                   Deploy a ceph cluster
rook-ceph-operator                  Install Rook operator for Ceph
$
```

## Bootstrap the cluster

### Talos Linux cluster

```console
$ make cluster-create # Pushing configurations and installing the nodes
```

In case of a configuration error, you can reset the nodes and destroy the cluster using the dedicated target:

```console
$ make cluster-reset
```

If you are using cloud instances or lab hardware, you might want to shutdown the cluster:

```console
$ make cluster-shutdown
```

### Layer-2 LoadBalancer class using Cilium

Two sets of objecs will be created: `CiliumLoadBalancerIPPool` and `CiliumL2AnnouncementPolicy`:

```console
$ make ciliun-l2 # Cilium L2 announcements
```

Let’s check that they exist:

```console
$ kubectl get CiliumLoadBalancerIPPool,CiliumL2AnnouncementPolicy
NAME                                              DISABLED   CONFLICTING   IPS AVAILABLE   AGE
ciliumloadbalancerippool.cilium.io/core-pool-l2   false      False         125             1m

NAME                                                 AGE
ciliuml2announcementpolicy.cilium.io/core-services   1m
$
```

### Deploy Ceph

Lets’s deploy Rook-Ceph storage layer:

```console
$ make rook-ceph-operator # Deploy the operator
$ make rook-ceph-cluster  # Deploy the cluster
```

Let’s wait for the storage layer to be ready:

```console
$ kubectl --namespace rook-ceph get cephcluster rook-ceph
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   PHASE   MESSAGE                        HEALTH        EXTERNAL   FSID
rook-ceph   /var/lib/rook     3          40m   Ready   Cluster created successfully   HEALTH_OK                ea9e2855-40e2-4e01-97a9-fd62147b7f15
$ kubectl get storageclass
NAME              PROVISIONER                  RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
rook-ceph-block   rook-ceph.rbd.csi.ceph.com   Delete          Immediate           true                   2m48s
$
```
