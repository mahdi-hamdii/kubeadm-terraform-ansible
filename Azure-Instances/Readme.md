# Unmanaged Kubernetes cluster in Azure VMs

This Folder creates a Kubernetes Cluster on Azure VMs using Kubeadm playbook.

## How to run the project

- Generate a public and private key using the `ssh-keygen` command. by defaut the public key is named `id_rsa.pub` but you can change it (variables.tf -> ssh_public_key) 

- Change the `private_ssh_key` variable value.
- Change the `public_ssh_key`variable value.

- Add your **Azure Credentials** as an environment variables:

```bash
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_SUBSCRIPTION_ID=""
export ARM_TENANT_ID=""
```

- Change the **resource_group_name** variable (variables.tf)

- Run the following commands to create the cluster:
    - `terraform init`
    - `terraform apply`

## How to access to the cluster

- to access the cluster you just need to: `export KUBECONFIG=./sensitive_data/kubeconfig`

## How to destroy the project

- Run `terraform destroy`
