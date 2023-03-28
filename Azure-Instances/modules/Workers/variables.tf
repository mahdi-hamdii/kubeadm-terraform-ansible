variable "workers" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "worker-nic-names" {
  type = list(string)
}

variable "worker_size" {
  type = string
}

variable "worker-admin-username" {
  type    = string
  default = "adminuser"
}
