resource_group_name = "DevOps-GL5"
location            = "France Central"
subscription_id     = "2bfd66e2-d8f3-4fa4-b3d2-a0e7bc2d39a0"
worker-nic-names    = ["worker-0-nic", "worker-1-nic"]
workers             = ["worker-0","worker-1"]
worker_size         = "Standard_B1s"
master_size         = "Standard_B2s"
security_rule_ssh = {
  name                   = "allow-ssh"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "22"
}