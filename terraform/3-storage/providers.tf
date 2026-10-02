terraform {
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "3.117.1" } }
  backend "azurerm" {
    resource_group_name  = "az-mothershipwest"
    storage_account_name = "jfaiopsblob"
    container_name       = "tfstate"
    key                  = "storage.terraform.tfstate"
  }
}
provider "azurerm" { 
features {} 
}
