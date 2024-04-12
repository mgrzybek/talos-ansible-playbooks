# Installing a cluster

This takes around 28 minutes:

- one controlplane
- three workers
- cilium operator
- 30 Mb broadband connection

| Env. variable  | Value      |
| -------------- | ---------- |
| CILIUM_VERSION | 1.15.1     |
| CLUSTER_NAME   | my-cluster |

```console
$ time make cluster-create
ansible-playbook -i ../inventory.ini -e cluster_name=my-cluster   playbooks/gen-conf.yml

PLAY [all] ********************************************************************************************************************************************************************************

TASK [Configuration generation | Assert variables] ****************************************************************************************************************************************
ok: [192.168.64.6] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [192.168.64.12] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [192.168.64.13] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [192.168.64.14] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Configuration generation | Check actual configuration] ******************************************************************************************************************************
ok: [192.168.64.6 -> localhost]

TASK [Create Cilium manifest] *************************************************************************************************************************************************************
changed: [192.168.64.6 -> localhost]

TASK [Create Cilium manifest] *************************************************************************************************************************************************************
ok: [192.168.64.6 -> localhost]

TASK [Create cilium patch] ****************************************************************************************************************************************************************
ok: [192.168.64.6]
ok: [192.168.64.12]
ok: [192.168.64.13]
ok: [192.168.64.14]

TASK [Write cilium patch] *****************************************************************************************************************************************************************
changed: [192.168.64.6 -> localhost]

TASK [Configuration generation | Create talos configuration for the cluster (talosconfig, worker.yaml, controlplane.yaml)] ****************************************************************
changed: [192.168.64.6 -> localhost]

PLAY RECAP ********************************************************************************************************************************************************************************
192.168.64.12              : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.64.13              : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.64.14              : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.64.6               : ok=7    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ansible-playbook -i ../inventory.ini -e cluster_name=cluster-uctm -l controlplane  playbooks/apply-conf.yml

PLAY [controlplane] ***********************************************************************************************************************************************************************

TASK [Applying machines’ configuration | Setting facts] ***********************************************************************************************************************************
ok: [192.168.64.6]

TASK [Applying machines’ configuration | Controlplane] ************************************************************************************************************************************
changed: [192.168.64.6 -> localhost]

TASK [Pause for 5 minutes to let the machine download the images] *************************************************************************************************************************
skipping: [192.168.64.6]

PLAY [worker] *****************************************************************************************************************************************************************************
skipping: no hosts matched

PLAY RECAP ********************************************************************************************************************************************************************************
192.168.64.6               : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

ansible-playbook -i ../inventory.ini -e cluster_name=cluster-uctm   playbooks/bootstrap.yml

PLAY [controlplane] ***********************************************************************************************************************************************************************

TASK [Bootstrap | Set facts] **************************************************************************************************************************************************************
ok: [192.168.64.6]

TASK [Bootstrap | Bootstrap talos controlplane (bootstrap of one etcd instance)] **********************************************************************************************************
FAILED - RETRYING: [192.168.64.6 -> localhost]: Bootstrap | Bootstrap talos controlplane (bootstrap of one etcd instance) (10 retries left).
FAILED - RETRYING: [192.168.64.6 -> localhost]: Bootstrap | Bootstrap talos controlplane (bootstrap of one etcd instance) (9 retries left).
ok: [192.168.64.6 -> localhost]

TASK [Bootstrap | Wait for the node to be ready] ******************************************************************************************************************************************
FAILED - RETRYING: [192.168.64.6 -> localhost]: Bootstrap | Wait for the node to be ready (5 retries left).
FAILED - RETRYING: [192.168.64.6 -> localhost]: Bootstrap | Wait for the node to be ready (4 retries left).
ok: [192.168.64.6 -> localhost]

TASK [Bootstrap | Get kubernetes configuration] *******************************************************************************************************************************************
changed: [192.168.64.6 -> localhost]

PLAY RECAP ********************************************************************************************************************************************************************************
192.168.64.6               : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ansible-playbook -i ../inventory.ini -e cluster_name=cluster-uctm -l worker  playbooks/apply-conf.yml

PLAY [controlplane] ***********************************************************************************************************************************************************************
skipping: no hosts matched

PLAY [worker] *****************************************************************************************************************************************************************************

TASK [Applying machines’ configuration | Setting facts] ***********************************************************************************************************************************
ok: [192.168.64.12]

TASK [Applying machines’ configuration | Workers] *****************************************************************************************************************************************
changed: [192.168.64.12 -> localhost]

TASK [Pause for 5 minutes to let the machine download the images] *************************************************************************************************************************
Pausing for 300 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [192.168.64.12]

PLAY [worker] *****************************************************************************************************************************************************************************

TASK [Applying machines’ configuration | Setting facts] ***********************************************************************************************************************************
ok: [192.168.64.13]

TASK [Applying machines’ configuration | Workers] *****************************************************************************************************************************************
changed: [192.168.64.13 -> localhost]

TASK [Pause for 5 minutes to let the machine download the images] *************************************************************************************************************************
Pausing for 300 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [192.168.64.13]

PLAY [worker] *****************************************************************************************************************************************************************************

TASK [Applying machines’ configuration | Setting facts] ***********************************************************************************************************************************
ok: [192.168.64.14]

TASK [Applying machines’ configuration | Workers] *****************************************************************************************************************************************
changed: [192.168.64.14 -> localhost]

TASK [Pause for 5 minutes to let the machine download the images] *************************************************************************************************************************
Pausing for 300 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [192.168.64.14]

PLAY RECAP ********************************************************************************************************************************************************************************
192.168.64.12              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.64.13              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.64.14              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

make cluster-create  22,29s user 16,35s system 2% cpu 28:17,80 total
$
```
