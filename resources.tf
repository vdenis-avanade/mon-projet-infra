# On utilise les variables ici avec var.nom_de_la_variable
resource "azurerm_resource_group" "rg_app" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet_app" {
  name                = "vnet-ma-super-application"
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name
  address_space       = var.vnet_address_space
}

# --- NOUVELLE RESSOURCE : LE SOUS-RÉSEAU ---
resource "azurerm_subnet" "subnet_frontend" {
  name                 = "snet-frontend"
  resource_group_name  = azurerm_resource_group.rg_app.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.0.1.0/24"]
}