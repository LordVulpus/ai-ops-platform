resource "azurerm_resource_group" "rg" {
  name     = "az-mothershipwest"
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                = "jf-mothership-keyvault"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = "e4817dd1-cf6e-4cc5-b76e-85d89aa6d3c2"
  rbac_authorization_enabled   = true
  public_network_access_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["82.19.157.212/32"]
    virtual_network_subnet_ids = [
      "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/az-mothershipwest/providers/Microsoft.Network/virtualNetworks/az-centralcomputervnet/subnets/az-centralcomputersubnet",
      "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/mc_az-mothershipwest_aiops-cluster_ukwest/providers/Microsoft.Network/virtualNetworks/aks-vnet-39605906/subnets/aks-subnet"
    ]
  }
}

resource "azurerm_ssh_public_key" "ssh_key" {
  name                = "CentralComputerKey"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  public_key          = var.ssh_public_key # No more hardcoded key string!
}

