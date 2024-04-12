# talos-ansible-playbooks

Ansible playbooks to provide Talos Linux + Cilium + Ceph deployments.

## Use cases

### Core services

- Talos Linux cluster with embedded Cilium CNI (layer2-3)
- Rook-Ceph-based storage

## Content

These are a set of playbooks used to operate Talos Linux clusters: day-0, day-1, day-2.

- [Day-0](./day-0/README.md): set prerequisites to deploy a cluster.
- [Day-1](./day-1/README.md): deploy a cluster.
- [Day-2](./day-2/README.md): add nodes, upgrade or destroy resources.
