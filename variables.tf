variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "rg-ma-super-application"
}

variable "location" {
  description = "Région Azure pour le déploiement"
  type        = string
  default     = "westeurope"
}

variable "vnet_address_space" {
  description = "Espace d'adressage du VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}