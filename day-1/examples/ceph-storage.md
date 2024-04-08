# Deploying Ceph

This takes around 5 minutes:
- one controlplane
- three workers
- three OSDs

| Env. variable  | Value      |
|----------------|------------|
| CILIUM_VERSION | 1.15.1     |
| CLUSTER_NAME   | my-cluster |

```console
$ time make rook-ceph-operator rook-ceph-cluster
kubectl apply -f manifests/rook.common.yaml
namespace/rook-ceph unchanged
clusterrole.rbac.authorization.k8s.io/cephfs-csi-nodeplugin unchanged
clusterrole.rbac.authorization.k8s.io/cephfs-external-provisioner-runner unchanged
clusterrole.rbac.authorization.k8s.io/objectstorage-provisioner-role unchanged
clusterrole.rbac.authorization.k8s.io/rbd-csi-nodeplugin unchanged
clusterrole.rbac.authorization.k8s.io/rbd-external-provisioner-runner unchanged
clusterrole.rbac.authorization.k8s.io/rook-ceph-cluster-mgmt unchanged
clusterrole.rbac.authorization.k8s.io/rook-ceph-global unchanged
clusterrole.rbac.authorization.k8s.io/rook-ceph-mgr-cluster unchanged
clusterrole.rbac.authorization.k8s.io/rook-ceph-mgr-system unchanged
clusterrole.rbac.authorization.k8s.io/rook-ceph-object-bucket unchanged
clusterrole.rbac.authorization.k8s.io/rook-ceph-osd unchanged
clusterrole.rbac.authorization.k8s.io/rook-ceph-system unchanged
clusterrolebinding.rbac.authorization.k8s.io/cephfs-csi-nodeplugin-role unchanged
clusterrolebinding.rbac.authorization.k8s.io/cephfs-csi-provisioner-role unchanged
clusterrolebinding.rbac.authorization.k8s.io/objectstorage-provisioner-role-binding unchanged
clusterrolebinding.rbac.authorization.k8s.io/rbd-csi-nodeplugin unchanged
clusterrolebinding.rbac.authorization.k8s.io/rbd-csi-provisioner-role unchanged
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-global unchanged
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-mgr-cluster unchanged
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-object-bucket unchanged
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-osd unchanged
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-system unchanged
role.rbac.authorization.k8s.io/cephfs-external-provisioner-cfg unchanged
role.rbac.authorization.k8s.io/rbd-csi-nodeplugin unchanged
role.rbac.authorization.k8s.io/rbd-external-provisioner-cfg unchanged
role.rbac.authorization.k8s.io/rook-ceph-cmd-reporter unchanged
role.rbac.authorization.k8s.io/rook-ceph-mgr unchanged
role.rbac.authorization.k8s.io/rook-ceph-osd unchanged
role.rbac.authorization.k8s.io/rook-ceph-purge-osd unchanged
role.rbac.authorization.k8s.io/rook-ceph-rgw unchanged
role.rbac.authorization.k8s.io/rook-ceph-system unchanged
rolebinding.rbac.authorization.k8s.io/cephfs-csi-provisioner-role-cfg unchanged
rolebinding.rbac.authorization.k8s.io/rbd-csi-nodeplugin-role-cfg unchanged
rolebinding.rbac.authorization.k8s.io/rbd-csi-provisioner-role-cfg unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-cluster-mgmt unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-cmd-reporter unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-mgr unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-mgr-system unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-osd unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-purge-osd unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-rgw unchanged
rolebinding.rbac.authorization.k8s.io/rook-ceph-system unchanged
serviceaccount/objectstorage-provisioner unchanged
serviceaccount/rook-ceph-cmd-reporter unchanged
serviceaccount/rook-ceph-mgr unchanged
serviceaccount/rook-ceph-osd unchanged
serviceaccount/rook-ceph-purge-osd unchanged
serviceaccount/rook-ceph-rgw unchanged
serviceaccount/rook-ceph-system unchanged
serviceaccount/rook-csi-cephfs-plugin-sa unchanged
serviceaccount/rook-csi-cephfs-provisioner-sa unchanged
serviceaccount/rook-csi-rbd-plugin-sa unchanged
serviceaccount/rook-csi-rbd-provisioner-sa unchanged
kubectl patch namespace rook-ceph -p '{ "metadata": { "labels": { "pod-security.kubernetes.io/enforce": "privileged" } } }'
namespace/rook-ceph patched (no change)
kubectl apply -f manifests/rook.crds.yaml  -f manifests/rook.operator.yaml
customresourcedefinition.apiextensions.k8s.io/cephblockpoolradosnamespaces.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephblockpools.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephbucketnotifications.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephbuckettopics.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephclients.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephclusters.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephcosidrivers.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephfilesystemmirrors.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephfilesystems.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephfilesystemsubvolumegroups.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephnfses.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephobjectrealms.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephobjectstores.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephobjectstoreusers.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephobjectzonegroups.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephobjectzones.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/cephrbdmirrors.ceph.rook.io unchanged
customresourcedefinition.apiextensions.k8s.io/objectbucketclaims.objectbucket.io unchanged
customresourcedefinition.apiextensions.k8s.io/objectbuckets.objectbucket.io unchanged
configmap/rook-ceph-operator-config unchanged
deployment.apps/rook-ceph-operator unchanged
kubectl -n rook-ceph wait deployment/rook-ceph-operator --for=condition=Available  --timeout=1h > /dev/null
kubectl apply -f manifests/rook.cluster.yaml
cephcluster.ceph.rook.io/rook-ceph created
make rook-ceph-operator rook-ceph-cluster  2,09s user 0,24s system 1% cpu 5:01,14 total
$
```
