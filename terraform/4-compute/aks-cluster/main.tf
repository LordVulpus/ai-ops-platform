resource "azurerm_resource_group" "rg" {
  name     = "az-mothershipwest"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  dns_prefix          = "aiops-clus-az-mothershipwes-c2c2dd"
  location            = var.location
  name                = "aiops-cluster"
  resource_group_name = azurerm_resource_group.rg.name
  default_node_pool {
    name = "nodepool1"
    upgrade_settings {
      max_surge = "10%"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }
  monitor_metrics {
  }
  oms_agent {
    log_analytics_workspace_id      = "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/DefaultResourceGroup-WUK/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-c2c2dd70-d73d-413c-8083-87a6e41b02e8-WUK"
    msi_auth_for_monitoring_enabled = true
  }
}
