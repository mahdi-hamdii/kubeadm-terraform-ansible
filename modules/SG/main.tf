resource "azurerm_network_security_group" "security_group" {
  name                = var.security_group_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = var.security_rule.name
    priority                   = var.security_rule.priority
    direction                  = var.security_rule.direction
    access                     = var.security_rule.access
    protocol                   = var.security_rule.protocol
    source_port_range          = var.security_rule.source_port_range
    destination_port_range     = var.security_rule.destination_port_range
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "sg_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.security_group.id
}