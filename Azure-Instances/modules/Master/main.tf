resource "azurerm_public_ip" "master-public-ip" {
  name                = "master-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "master-nic" {
  name                = "master-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.master-public-ip.id
    private_ip_address            = "10.0.2.8"
  }
}

resource "azurerm_linux_virtual_machine" "master" {
  name                = "master"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
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

}
