# kubeadm-terraform-ansible
Provision kubernetes cluster on Azure with Terraform and ansible


# What is Kubeadm
Kubeadm is a tool used to build Kubernetes (K8s) clusters. Kubeadm performs the actions necessary to get a minimum viable cluster up and running quickly. By design, it cares only about bootstrapping, not about provisioning machines (underlying worker and master nodes).

The following Steps Will launch a Master a n Worker nodes:

1. Terraform init
2. Terraform plan
3. Terraform apply
