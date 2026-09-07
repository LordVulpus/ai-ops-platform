resource "azurerm_resource_group" "rg" {
  name     = "az-mothershipwest"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}VNET"
  location            = var.location
  resource_group_name = "az-mothershipwest"
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "subnet" {
  name                 = "az-centralcomputerSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}
