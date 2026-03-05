# Récupère l'identité actuelle (le Service Principal GitHub Actions)
data "azurerm_client_config" "current" {}

# Génère un mot de passe aléatoire de 16 caractères
resource "random_password" "vm_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

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
  name                = var.nsg_name
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name
}


resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(var.http_port)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_app.name
  network_security_group_name = azurerm_network_security_group.nsg_app.name
}


resource "azurerm_subnet_network_security_group_association" "snet_nsg_link" {
  subnet_id                 = azurerm_subnet.subnet_frontend.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}


resource "azurerm_public_ip" "pip_app" {
  name                = "pip-app"
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nic_app" {
  name                = "nic-app"
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_frontend.id # On le branche sur ton subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_app.id # On lui donne l'IP publique
  }
}

resource "azurerm_key_vault" "kv_app" {
  name                        = "kv-monprojet-vd-345287" # À CHANGER POUR ÊTRE UNIQUE
  location                    = azurerm_resource_group.rg_app.location
  resource_group_name         = azurerm_resource_group.rg_app.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  # On donne le droit à Terraform (GitHub Actions) de lire et écrire des secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "Set", "Delete", "Purge", "Recover", "List"
    ]
  }
}

# On crée un Secret dans le Key Vault contenant le mot de passe généré
resource "azurerm_key_vault_secret" "vm_password_secret" {
  name         = "admin-password-vm"
  value        = random_password.vm_password.result
  key_vault_id = azurerm_key_vault.kv_app.id
}

# 3. La Machine Virtuelle Linux
resource "azurerm_linux_virtual_machine" "vm_app" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location
  size                = "Standard_B2ts_v2"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic_app.id,
  ]

  # Pour simplifier, on utilise un mot de passe (en vrai on mettrait une clé SSH)
  admin_password                  = random_password.vm_password.result
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}