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


resource "azurerm_subnet" "subnet_frontend" {
  name                 = "snet-frontend"
  resource_group_name  = azurerm_resource_group.rg_app.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg_app" {
  name                = var.nsg_name # <--- On utilise la variable
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name
}

# 2. On crée une règle spécifique pour autoriser le HTTP (Port 80)
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.http_port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_app.name
  network_security_group_name = azurerm_network_security_group.nsg_app.name
}

# 3. LE LIEN : On attache le NSG au Subnet qu'on a créé tout à l'heure
resource "azurerm_subnet_network_security_group_association" "snet_nsg_link" {
  subnet_id                 = azurerm_subnet.subnet_frontend.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}