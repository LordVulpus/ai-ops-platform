terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  backend "azurerm" {
    resource_group_name  = "az-mothershipwest"
    storage_account_name = "jfaiopsblob" # Change to your actual storage account name
    container_name       = "tfstate"                   # The blob container name
    key                  = "networking.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
  subscription_id                 = "c2c2dd70-d73d-413c-8083-87a6e41b02e8"
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
}
