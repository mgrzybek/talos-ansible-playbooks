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
$ make rook-ceph-operator # Deploy the operator
```

Then, the disks should be declared properly, the given spec should be patched.
```yaml
spec:
  storage: 
    useAllNodes: true
    useAllDevices: false
    deviceFilter: "^vdb" # You should update the filter
```

Let’s create the resources.
```console
$ vim manifests/rook.cluster.yaml # Edit the manifest shown below
$ make rook-ceph-cluster
```

Let’s wait for the storage layer to be ready.
```console
$ watch kubectl -n rook-ceph get pods # Wait some time…
Every 2,0s: kubectl -n rook-ceph get pods                                                                                                                                                                                      computer.local: Fri Apr  5 20:40:10 2024
[…]

NAME                                                      READY   STATUS      RESTARTS      AGE
csi-cephfsplugin-2wvpm                                    2/2     Running     1 (25m ago)   27m
csi-cephfsplugin-77nrm                                    2/2     Running     0             27m
csi-cephfsplugin-provisioner-fb7dd6764-76vwl              5/5     Running     4 (19m ago)   27m
csi-cephfsplugin-provisioner-fb7dd6764-ph8fl              5/5     Running     4 (21m ago)   27m
csi-cephfsplugin-pvfcq                                    2/2     Running     1 (26m ago)   27m
csi-rbdplugin-28zjn                                       2/2     Running     0             27m
csi-rbdplugin-kr4s2                                       2/2     Running     1 (26m ago)   27m
csi-rbdplugin-mlvgd                                       2/2     Running     1 (25m ago)   27m
csi-rbdplugin-provisioner-5f69d6ffbc-9hjns                5/5     Running     3 (20m ago)   27m
csi-rbdplugin-provisioner-5f69d6ffbc-jmprm                5/5     Running     4 (21m ago)   27m
rook-ceph-crashcollector-talos-a3l-w7p-5949cd97bf-498ch   1/1     Running     0             88s
rook-ceph-crashcollector-talos-fxh-oar-7c4c4d8db7-wvm5j   1/1     Running     0             99s
rook-ceph-crashcollector-talos-tik-aoi-db468cf7d-dcv8m    1/1     Running     0             86s
rook-ceph-mgr-a-6d7789bd6f-8bdsh                          3/3     Running     0             119s
rook-ceph-mgr-b-85fc79679b-chjdz                          3/3     Running     0             119s
rook-ceph-mon-a-85c4f55df-bfbbm                           2/2     Running     0             12m
rook-ceph-mon-b-86c96d6d57-cgbnj                          2/2     Running     0             2m20s
rook-ceph-mon-c-676bb7c6d7-vzz7g                          2/2     Running     0             2m10s
rook-ceph-operator-58cc888c68-4pnfq                       1/1     Running     0             38m
rook-ceph-osd-0-6fb479cdbc-rmm4d                          2/2     Running     0             88s
rook-ceph-osd-1-ffb94f947-5txl6                           2/2     Running     0             87s
rook-ceph-osd-2-8555ffc5f8-f5r72                          2/2     Running     0             86s
rook-ceph-osd-prepare-talos-a3l-w7p-rtbtm                 0/1     Completed   0             60s
rook-ceph-osd-prepare-talos-fxh-oar-2hrp8                 0/1     Completed   0             57s
rook-ceph-osd-prepare-talos-tik-aoi-88rfw                 0/1     Completed   0             54s

$ kubectl --namespace rook-ceph get cephcluster rook-ceph
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   PHASE   MESSAGE                        HEALTH        EXTERNAL   FSID
rook-ceph   /var/lib/rook     3          40m   Ready   Cluster created successfully   HEALTH_OK                ea9e2855-40e2-4e01-97a9-fd62147b7f15
$ kubectl get storageclass
```

## Deploy the deployment stack

```console
$ export SIDERO_CONTROLLER_MANAGER_HOST_NETWORK=false # We use MetalLB
$ export SIDERO_CONTROLLER_MANAGER_DEPLOYMENT_STRATEGY=Recreate
$ export SIDERO_CONTROLLER_MANAGER_API_ENDPOINT= # MetalLB floating IP for Sidero API
$ export SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT= # MetalLB floating IP for Siredolinks’s Wireguard

$ make sidero-metal # Deploy sidero metal
```