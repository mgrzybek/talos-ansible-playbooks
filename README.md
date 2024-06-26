# talos-ansible-playbooks

Ansible playbooks to provide Talos Linux + Cilium + Ceph deployments.

## Use cases

### Core services

| Name      | Description                                                      | URL                    |
|-----------|------------------------------------------------------------------|------------------------|
| Talos     | Linux designed for Kubernetes                                    | https://www.talos.dev/ |
| Cilium    | CNI to provide eBPF-based Networking, Observability and Security | https://cilium.io/     |
| Rook-Ceph | Production ready management for File, Block and Object Storage   | https://rook.io/       |

### Middlewares

| Name       | Description                           | URL                     |
|------------|---------------------------------------|-------------------------|
| Tinkerbell | Bare metal machines provisioning tool | https://tinkerbell.org/ |

## Content

These are a set of playbooks used to operate Talos Linux clusters: day-0, day-1, day-2.

- [Day-0](./day-0/README.md): set prerequisites to deploy a cluster.
- [Day-1](./day-1/README.md): deploy a cluster.
- [Day-2](./day-2/README.md): add nodes, upgrade or destroy resources.
