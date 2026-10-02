# terraform/4-compute/aks-cluster/main.tf

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 1. Reference your existing secure storage account parameters
data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.rg.name
}

# 2. Reference your live cloud SSH Public Key Asset directly
data "azurerm_ssh_public_key" "cluster_key" {
  name                = var.jumpbox_key_name # Maps to "PortfolioJumpboxKey"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aiops-clus-az-mothershipwes-c2c2dd"
  kubernetes_version  = "1.33" 

  default_node_pool {
    name            = "nodepool1" 
    node_count      = 1
    vm_size         = "Standard_B2s_v2" 
    vnet_subnet_id  = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/az-centralcomputerVNET/subnets/az-centralcomputerSubnet"
    
    upgrade_settings {
      max_surge = "10%"
    }
  }

  oidc_issuer_enabled       = false
  workload_identity_enabled = false

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      # Securely extracts your real public key data from the Azure asset at runtime
      key_data = data.azurerm_ssh_public_key.cluster_key.public_key
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay" 
    load_balancer_sku   = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = "/subscriptions/${var.subscription_id}/resourceGroups/DefaultResourceGroup-WUK/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-${var.subscription_id}-WUK"
  }

  # Fixed syntax: Explicit list index targeting for newer Terraform schema engines
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      linux_profile[0].ssh_key
    ]
  }
}

# PROTECT THE APP ROLE DEFINITION: Fixed with explicit identity array indexing [0]
resource "azurerm_role_assignment" "aks_storage_access" {
  scope                = data.azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
