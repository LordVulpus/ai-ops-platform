resource "azurerm_kubernetes_cluster" "res-0" {
  dns_prefix          = "aiops-clus-az-mothershipwes-c2c2dd"
  location            = "ukwest"
  name                = "aiops-cluster"
  resource_group_name = "az-mothershipwest"
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
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChfo9De6CQzC8h4SBZgqAqJI0EicZ0T2rXpmZDIz2jStRwGf4o5/aLTTn4VgiYyWCEURVZ7ddQr5x4i+BGRgHEVtwxcLI3wcd0QYorExVEaC+zkF3WtKxDuPxXL0c+ZuxlnwZg0suc5v9l3uvOGEiAaeiaKNnklTdmKSrMj+g3z1WPEUEk+f70EyX4IVaP3sSFCpBWQt3PO2557iykQUtT0bvUenqvKeMY2gASX+AiCBIA2xPRamTIcbvhhZfFChckKpJFUzQdewyGQoiUDUNyZE+ST2anRLLj0zT+NWLXOITOmZ6Ior1CQSuKj0fr9Gthqw9Aja+zayi6ABs4YXDH"
    }
  }
  monitor_metrics {
  }
  oms_agent {
    log_analytics_workspace_id      = "/subscriptions/c2c2dd70-d73d-413c-8083-87a6e41b02e8/resourceGroups/DefaultResourceGroup-WUK/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-c2c2dd70-d73d-413c-8083-87a6e41b02e8-WUK"
    msi_auth_for_monitoring_enabled = true
  }
}
