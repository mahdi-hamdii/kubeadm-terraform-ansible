output "public_ips" {
  value = azurerm_linux_virtual_machine.workers.*.public_ip_address
}
