resource "azurerm_virtual_network" "virtual-network" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  address_prefixes     = ["10.0.2.0/24"]
}