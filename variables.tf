variable "resource_group_name" {
  type        = string
  description = "Nom du groupe de ressources"
}

variable "location" {
  type        = string
  description = "Région Azure"
}

variable "vnet_address_space" {
  type = list(string)
}

variable "nsg_name" {
  type = string
}

variable "http_port" {
  type = number
}

variable "vm_name" {
  type        = string
  description = "Nom de la machine virtuelle"
}

variable "admin_username" {
  type        = string
  description = "Nom d'utilisateur administrateur"
  default     = "azureuser"
}