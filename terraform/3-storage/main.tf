resource "azurerm_resource_group" "rg" {
  name     = "az-mothershipwest"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  location            = var.location
  name                = "aiopsregistry15069"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
}

resource "azurerm_storage_account" "storage" {
  name                            = "jfaiopsblob" # Kept hardcoded for safety
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2" # Upgraded to 1.2 for modern security compliance!
}
