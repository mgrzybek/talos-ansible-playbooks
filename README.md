# talos-ansible-playbooks

Ansible playbooks to manage Talos Linux deployments.

## Use cases

These playbooks can be used to deploy an autonomous / bootstrap cluster using a simple admin machine.

Some interesting core services to deploy:

- hosting [Sidero Metal](https://www.sidero.dev) to deploy other clusters within the data centre
- hosting an observability stack
- hosting identity services and directories
- hosting an underlay network controlplane such as [Headscale](https://github.com/juanfont/headscale) or [Nebula](https://github.com/slackhq/nebula).

## Content

These are a set of playbooks used to operate Talos Linux clusters: day-0, day-1, day-2.

- [Day-0](./day-0/README.md): set prerequisites to deploy a cluster.
- [Day-1](./day-1/README.md): create configurations and deploy a cluster.
- [Day-2](./day-2/README.md): add nodes, upgrade or destroy resources.
