variable "subnet_id" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "security_rule" {
  type = object({
    name                = string
    priority            = string
    direction              = string
    access                 = string
    protocol               = string
    source_port_range      = string
    destination_port_range = string
  })
}