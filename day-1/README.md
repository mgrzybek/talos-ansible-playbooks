# Day-1 operations

## Bootstrap

```console
$ make cluster-create
```

## Deploy the desired storage layer

```console
$ make rook-ceph-operator # Deploy the operator
$ make rook-ceph-cluster  # Deploy the cluster
```

Let’s wait for the storage layer to be ready.

```console
$ kubectl --namespace rook-ceph get cephcluster rook-ceph
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   PHASE   MESSAGE                        HEALTH        EXTERNAL   FSID
rook-ceph   /var/lib/rook     3          40m   Ready   Cluster created successfully   HEALTH_OK                ea9e2855-40e2-4e01-97a9-fd62147b7f15
$ kubectl get storageclass
```
