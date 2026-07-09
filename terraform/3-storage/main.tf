resource "azurerm_container_registry" "res-0" {
  location            = "ukwest"
  name                = "aiopsregistry15069"
  resource_group_name = "az-mothershipwest"
  sku                 = "Basic"
}
