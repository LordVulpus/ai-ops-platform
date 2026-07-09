resource "azurerm_public_ip" "res-0" {
  allocation_method   = "Static"
  location            = "ukwest"
  name                = "az-centralcomputerPublicIP"
  resource_group_name = "az-mothershipwest"
}
