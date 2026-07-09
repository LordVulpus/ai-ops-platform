resource "azurerm_virtual_network" "res-0" {
  address_space       = ["10.0.0.0/16"]
  location            = "ukwest"
  name                = "az-centralcomputerVNET"
  resource_group_name = "az-mothershipwest"
}
