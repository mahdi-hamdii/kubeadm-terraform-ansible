output "master_public_ip" {
  value = azurerm_linux_virtual_machine.master.public_ip_address
}
