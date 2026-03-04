resource "azurerm_resource_group" "rg_app" {
  name     = "rg-ma-super-application"
  location = "westeurope"
}

# --- NOUVEAU CODE À AJOUTER ---
resource "azurerm_virtual_network" "vnet_app" {
  name = "vnet-ma-super-application"
  # Remarque la magie d'IaC : on ne tape pas le nom à la main, 
  # on fait référence au groupe de ressources au-dessus !
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name
  address_space       = ["10.0.0.0/16"]
}