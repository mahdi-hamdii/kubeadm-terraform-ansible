variable "resource_group_name" {
  type        = string
  description = "RG name in azure"
}

variable "location" {
  type        = string
  description = "Ressources location in Azure"
}

variable "subscription_id" {
  type        = string
  description = "Azure Used subscription"
}

variable "worker-nic-names" {
  type = list(string)
}

variable "workers" {
  type = list(string)
}

variable "worker_size" {
  type = string
}

variable "worker-admin-username" {
  type    = string
  default = "adminuser"
}

variable "security_group_name" {
  type    = string
  default = "allow-ssh"
}
//dummy comment test
variable "security_rule_ssh" {
  type = object({
    name                   = string
    priority               = string
    direction              = string
    access                 = string
    protocol               = string
    source_port_range      = string
    destination_port_range = string
  })
}

variable "private_key_path" {
  type    = string
  default = "./gl5-ssh.pem"
}

variable "master_size" {
  type = string
}
