resource "azurerm_public_ip" "workers-public-ips" {
  count               = length(var.worker-nic-names)
  name                = var.workers[count.index]
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "worker-nics" {
  count               = length(var.worker-nic-names)
  name                = var.worker-nic-names[count.index]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.workers-public-ips[count.index].id

  }
}

resource "azurerm_linux_virtual_machine" "workers" {
  count               = length(var.workers)
  name                = var.workers[count.index]
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
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
