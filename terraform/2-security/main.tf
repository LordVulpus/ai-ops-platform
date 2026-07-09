resource "azurerm_key_vault" "res-0" {
  location            = "westeurope"
  name                = "jf-mothership-keyvault"
  resource_group_name = "az-mothershipwest"
  sku_name            = "standard"
  tenant_id           = "e4817dd1-cf6e-4cc5-b76e-85d89aa6d3c2"
}
