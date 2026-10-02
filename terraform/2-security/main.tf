# terraform/2-security/main.tf

# 1. Reference your core resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Map your live jf-mothership-keyvault with flexible network rule tracking
resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = "westeurope"
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [] # Kept empty so code stays generic
    virtual_network_subnet_ids = [
      "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/az-centralcomputervnet/subnets/az-centralcomputersubnet",
      "/subscriptions/${var.subscription_id}/resourceGroups/mc_az-mothershipwest_aiops-cluster_ukwest/providers/Microsoft.Network/virtualNetworks/aks-vnet-39605906/subnets/aks-subnet"
    ]
  }

  # CRITICAL: Ignores dynamic IP rule modifications made via Portal/CLI at runtime
  lifecycle {
    ignore_changes = [
      network_acls[0].ip_rules
    ]
  }
}

# 3. Map your live az-centralcomputerNSG to prevent modification drops
resource "azurerm_network_security_group" "nsg" {
  name                = "az-centralcomputerNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  lifecycle {
    ignore_changes = [security_rule]
  }
}
