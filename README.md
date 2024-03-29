# What is Kubeadm
> kubeadm performs the actions necessary to get a minimum viable cluster up and running. 
>By design, it cares only about bootstrapping, not about provisioning machines.
<img src="https://d33wubrfki0l68.cloudfront.net/e4a8ddb49f07de8b2c2dbbfc7c9bedcfe0816701/600b1/images/kubeadm-stacked-color.png" width="150" height="150" />

# Terraform 
> Terraform is an infrastructure as code tool that lets you build, change, and version cloud and on-prem resources safely and efficiently.

<img src="https://blog.stephane-robert.info/img/Terraform-logo-small.png" width="150" height="150" />

To provision the infrastructure we need to execute: 
1. Terraform init
2. Terraform apply

## Provisionnig Infrastructure

> We will use Terraform to provision a Master node and n worker nodes:

- Add your **Azure Credentials** as an environment variables:

```bash
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_SUBSCRIPTION_ID=""
export ARM_TENANT_ID=""
```


| Modules       | Roles                                                                 | 
| ------------- | -------------     |
| Master        | Create the master node for the K8s cluster and assign it a public ip  |
| Workers       | creates n worker nodes                                                |
| SG            | Network security group rules                                          | 
| VNET          | creates clusters Virtual Network and subnets                          |

<img src="https://blog.stephane-robert.info/img/Terraform-logo-small.png" width="150" height="150" />

To provision the infrastructure we need to execute: 
1. Terraform init
2. Terraform apply

## Configuring Nodes the old way (Kube version 1.23.0)
> After provisionning the infrastructure terraform will automatically call an ansible playbook that will configure K8s cluter
- Setup kubeadm env on all instances: install Docker CE, kubeadm kubelet and kubectl. 
- Initialize Master Node: Initiliaze master node using Calico
- Generate Join Token and save it to a local buffer
- Copy and execute join Token on worker Nodes

| Ansible Roles       | Description                                                                 | 
| ------------- | -------------     |
| kubernetes-env-setup        | Check Repository for full documentation  |
| master-init       | Check Repository for full documentation  |

<img src="https://upload.wikimedia.org/wikipedia/commons/2/24/Ansible_logo.svg" width="150" height="150" />

## Configuring Nodes the new Way (kube version 1.26.0)
> After provisionning the infrastructure terraform will automatically call an ansible playbook that will configure K8s cluter

<img src="https://upload.wikimedia.org/wikipedia/commons/2/24/Ansible_logo.svg" width="150" height="150" />

- Setup kubeadm env on all instances: install Containerd, kubeadm kubelet and kubectl. 
- Initialize Master Node: Initiliaze master node using Calico
- Generate Join Token and save it to a local buffer
- Copy and execute join Token on worker Nodes

| Ansible Roles       | Description                                                                 | 
| ------------- | -------------     |
| Kube-prerequisites       | Configures the prerequisites for all nodes  |
| Containerd       | Installs Containerd  |
| Kubeadm-kubelet-kubectl      | Installs kubeadm-kubelet-kubectl  |
| cluster-init      | Mounts the cluster on the Master Node  |


