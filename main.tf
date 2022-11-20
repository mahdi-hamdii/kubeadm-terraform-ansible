data "azurerm_resource_group" "resource-grp" {
  name = var.resource_group_name
}

module "vnet_subnet" {
  source                  = "./modules/VNET-subnet"
  resource_group_name     = var.resource_group_name
  resource_group_location = data.azurerm_resource_group.resource-grp.location
  vnet_name               = "kubernetes-virtual-network"
  subnet_name             = "kubernetes-subnet"
}

module "security_group" {
  source                  = "./modules/SG"
  resource_group_name     = var.resource_group_name
  resource_group_location = data.azurerm_resource_group.resource-grp.location
  security_group_name     = var.security_group_name
  security_rule           = var.security_rule_ssh
  subnet_id               = module.vnet_subnet.subnet_id
}

module "workers" {
  source                  = "./modules/Workers"
  resource_group_name     = var.resource_group_name
  resource_group_location = data.azurerm_resource_group.resource-grp.location
  subnet_id               = module.vnet_subnet.subnet_id
  worker-nic-names        = var.worker-nic-names
  worker_size             = var.worker_size
  worker-admin-username   = var.worker-admin-username
  workers                 = var.workers
}

module "master" {
  source                  = "./modules/Master"
  resource_group_name     = var.resource_group_name
  resource_group_location = data.azurerm_resource_group.resource-grp.location
  subnet_id               = module.vnet_subnet.subnet_id
  master_size             = var.master_size

}

resource "local_file" "ansible_inventory" {
  depends_on = [
    module.master,
    module.workers
  ]
  content = templatefile("hosts.ini",
    {
      user    = "adminuser"
      prefix  = "kubeadm"
      workers = module.workers.public_ips
      master  = module.master.master_public_ip
    }
  )
  filename = "hosts-result.ini"
}

resource "null_resource" "execute_ansible" {
  depends_on = [
    local_file.ansible_inventory
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i hosts-result.ini, --private-key gl5-ssh.pen kubernetes.yaml"
  }
}
