# Deploying Ceph

This takes around 6 minutes:

- one controlplane
- three workers
- three OSDs

| Env. variable  | Value      |
| -------------- | ---------- |
| CILIUM_VERSION | 1.15.1     |
| CLUSTER_NAME   | my-cluster |

```console
$ time make rook-ceph-cluster
kubectl apply -f manifests/rook.common.yaml
namespace/rook-ceph created
clusterrole.rbac.authorization.k8s.io/cephfs-csi-nodeplugin created
clusterrole.rbac.authorization.k8s.io/cephfs-external-provisioner-runner created
clusterrole.rbac.authorization.k8s.io/objectstorage-provisioner-role created
clusterrole.rbac.authorization.k8s.io/rbd-csi-nodeplugin created
clusterrole.rbac.authorization.k8s.io/rbd-external-provisioner-runner created
clusterrole.rbac.authorization.k8s.io/rook-ceph-cluster-mgmt created
clusterrole.rbac.authorization.k8s.io/rook-ceph-global created
clusterrole.rbac.authorization.k8s.io/rook-ceph-mgr-cluster created
clusterrole.rbac.authorization.k8s.io/rook-ceph-mgr-system created
clusterrole.rbac.authorization.k8s.io/rook-ceph-object-bucket created
clusterrole.rbac.authorization.k8s.io/rook-ceph-osd created
clusterrole.rbac.authorization.k8s.io/rook-ceph-system created
clusterrolebinding.rbac.authorization.k8s.io/cephfs-csi-nodeplugin-role created
clusterrolebinding.rbac.authorization.k8s.io/cephfs-csi-provisioner-role created
clusterrolebinding.rbac.authorization.k8s.io/objectstorage-provisioner-role-binding created
clusterrolebinding.rbac.authorization.k8s.io/rbd-csi-nodeplugin created
clusterrolebinding.rbac.authorization.k8s.io/rbd-csi-provisioner-role created
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-global created
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-mgr-cluster created
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-object-bucket created
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-osd created
clusterrolebinding.rbac.authorization.k8s.io/rook-ceph-system created
role.rbac.authorization.k8s.io/cephfs-external-provisioner-cfg created
role.rbac.authorization.k8s.io/rbd-csi-nodeplugin created
role.rbac.authorization.k8s.io/rbd-external-provisioner-cfg created
role.rbac.authorization.k8s.io/rook-ceph-cmd-reporter created
role.rbac.authorization.k8s.io/rook-ceph-mgr created
role.rbac.authorization.k8s.io/rook-ceph-osd created
role.rbac.authorization.k8s.io/rook-ceph-purge-osd created
role.rbac.authorization.k8s.io/rook-ceph-rgw created
role.rbac.authorization.k8s.io/rook-ceph-system created
rolebinding.rbac.authorization.k8s.io/cephfs-csi-provisioner-role-cfg created
rolebinding.rbac.authorization.k8s.io/rbd-csi-nodeplugin-role-cfg created
rolebinding.rbac.authorization.k8s.io/rbd-csi-provisioner-role-cfg created
rolebinding.rbac.authorization.k8s.io/rook-ceph-cluster-mgmt created
rolebinding.rbac.authorization.k8s.io/rook-ceph-cmd-reporter created
rolebinding.rbac.authorization.k8s.io/rook-ceph-mgr created
rolebinding.rbac.authorization.k8s.io/rook-ceph-mgr-system created
rolebinding.rbac.authorization.k8s.io/rook-ceph-osd created
rolebinding.rbac.authorization.k8s.io/rook-ceph-purge-osd created
rolebinding.rbac.authorization.k8s.io/rook-ceph-rgw created
rolebinding.rbac.authorization.k8s.io/rook-ceph-system created
serviceaccount/objectstorage-provisioner created
serviceaccount/rook-ceph-cmd-reporter created
serviceaccount/rook-ceph-mgr created
serviceaccount/rook-ceph-osd created
serviceaccount/rook-ceph-purge-osd created
serviceaccount/rook-ceph-rgw created
serviceaccount/rook-ceph-system created
serviceaccount/rook-csi-cephfs-plugin-sa created
serviceaccount/rook-csi-cephfs-provisioner-sa created
serviceaccount/rook-csi-rbd-plugin-sa created
serviceaccount/rook-csi-rbd-provisioner-sa created
kubectl patch namespace rook-ceph -p '{ "metadata": { "labels": { "pod-security.kubernetes.io/enforce": "privileged" } } }'
namespace/rook-ceph patched
kubectl apply -f manifests/rook.crds.yaml -f manifests/rook.operator.yaml
customresourcedefinition.apiextensions.k8s.io/cephblockpoolradosnamespaces.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephblockpools.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephbucketnotifications.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephbuckettopics.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephclients.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephclusters.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephcosidrivers.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephfilesystemmirrors.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephfilesystems.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephfilesystemsubvolumegroups.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephnfses.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephobjectrealms.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephobjectstores.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephobjectstoreusers.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephobjectzonegroups.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephobjectzones.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/cephrbdmirrors.ceph.rook.io created
customresourcedefinition.apiextensions.k8s.io/objectbucketclaims.objectbucket.io created
customresourcedefinition.apiextensions.k8s.io/objectbuckets.objectbucket.io created
configmap/rook-ceph-operator-config created
Warning: would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "rook-ceph-operator" must set securityContext.allowPrivilegeEscalation=false), seccompProfile (pod or container "rook-ceph-operator" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
deployment.apps/rook-ceph-operator created
kubectl -n rook-ceph wait deployment/rook-ceph-operator --for=condition=Available  --timeout=1h > /dev/null
ansible-playbook -i ../inventory.ini   playbooks/cilium-l2.yml

PLAY [controlplane] ****************************************************************************************************************************************

TASK [Cilium L2 | Check the required variables] ************************************************************************************************************
ok: [192.168.64.6] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Cilium L2 | Create CiliumLoadBalancerIPPool] *********************************************************************************************************
changed: [192.168.64.6 -> localhost]

TASK [Cilium L2 | Create CiliumL2AnnouncementPolicy] *******************************************************************************************************
changed: [192.168.64.6 -> localhost]

PLAY RECAP *************************************************************************************************************************************************
192.168.64.6               : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ansible-playbook -i ../inventory.ini   playbooks/ceph-cluster.yml

PLAY [controlplane] ****************************************************************************************************************************************

TASK [Ceph Cluster | Create the cluster] *******************************************************************************************************************
ok: [192.168.64.6 -> localhost]

TASK [Ceph Cluster | Wait for the cluster to be started (5 minutes per host * number of hosts)] ************************************************************
FAILED - RETRYING: [192.168.64.6 -> localhost]: Ceph Cluster | Wait for the cluster to be started (5 minutes per host * number of hosts) (1 retries left).
ok: [192.168.64.6 -> localhost]

TASK [Ceph Cluster | Create the pool] **********************************************************************************************************************
ok: [192.168.64.6 -> localhost]

TASK [Ceph Cluster | Create the Cilium L2 Load Balancer for the manager] ***********************************************************************************
changed: [192.168.64.6 -> localhost]

PLAY RECAP *************************************************************************************************************************************************
192.168.64.6               : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

make rook-ceph-cluster  6,03s user 2,79s system 2% cpu 5:54,21 total
$
```
