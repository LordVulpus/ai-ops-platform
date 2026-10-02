# terraform/1-networking/main.tf

# 1. Reference your core resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Map your live core Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "az-centralcomputerVNET"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# 3. Map your live core Subnet with its required secure service endpoints
resource "azurerm_subnet" "subnet" {
  name                 = "az-centralcomputerSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  
  # Preserves secure cloud network routing to your vault
  service_endpoints    = ["Microsoft.KeyVault"]
}
