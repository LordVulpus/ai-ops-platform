# terraform/3-storage/main.tf

# 1. Tracked as a managed resource matching your live state file map
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Renamed block identifier from "sa" to "storage" matching your state map
resource "azurerm_storage_account" "storage" {
  name                             = var.storage_account_name
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false # Locked to prevent in-place changes
  cross_tenant_replication_enabled = false # Locked to prevent in-place changes
}

# 3. Aligned SKU to "Basic" matching your live container registry tier
resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

# ==========================================================
# EVENT HUB COST TOGGLE (Kept out of live state to save cost)
# ==========================================================
variable "enable_telemetry_hub" {
  type        = bool
  description = "Toggle to false to keep Event Hub costs at absolute zero."
  default     = false
}

resource "azurerm_eventhub_namespace" "eh_ns" {
  count               = var.enable_telemetry_hub ? 1 : 0
  name                = "aiops-telemetry-evhns"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name # <--- Corrected: Dropped "data."
  sku                 = "Standard"
}
