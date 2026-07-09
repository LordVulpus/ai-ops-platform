provider "azurerm" {
  features {
  }
  use_oidc                        = false
  resource_provider_registrations = "none"
  subscription_id                 = "c2c2dd70-d73d-413c-8083-87a6e41b02e8"
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
}
