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
resource "azurerm_public_ip" "workers-public-ips" {
  count               = length(var.worker-nic-names)
  name                = var.workers[count.index]
  resource_group_name = data.azurerm_resource_group.resource-grp.name
  location            = data.azurerm_resource_group.resource-grp.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "worker-nics" {
  count               = length(var.worker-nic-names)
  name                = var.worker-nic-names[count.index]
  location            = data.azurerm_resource_group.resource-grp.location
  resource_group_name = data.azurerm_resource_group.resource-grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet_subnet.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.workers-public-ips[count.index].id

  }
}

resource "azurerm_linux_virtual_machine" "workers" {
  count               = length(var.workers)
  name                = var.workers[count.index]
  resource_group_name = data.azurerm_resource_group.resource-grp.name
  location            = data.azurerm_resource_group.resource-grp.location
  size                = var.worker_size
  admin_username      = var.worker-admin-username
  admin_ssh_key {
    username   = var.worker-admin-username
    public_key = file("./id_rsa.pub")
  }
  network_interface_ids = [
    azurerm_network_interface.worker-nics[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "master-public-ip" {
  name                = "master-public-ip"
  resource_group_name = data.azurerm_resource_group.resource-grp.name
  location            = data.azurerm_resource_group.resource-grp.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "master-nic" {
  name                = "master-nic"
  location            = data.azurerm_resource_group.resource-grp.location
  resource_group_name = data.azurerm_resource_group.resource-grp.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet_subnet.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.master-public-ip.id

  }
}

resource "azurerm_linux_virtual_machine" "master" {
  name                = "master"
  resource_group_name = data.azurerm_resource_group.resource-grp.name
  location            = data.azurerm_resource_group.resource-grp.location
  size                = var.master_size
  admin_username      = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.master-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.worker-admin-username
      private_key = file("./gl5-ssh.pem")
      host        = azurerm_linux_virtual_machine.master.public_ip_address
    }

    inline = ["echo 'connected!'"]
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${azurerm_linux_virtual_machine.master.public_ip_address}, --private-key ${var.private_key_path} kubeadm.yaml"
  }
}
