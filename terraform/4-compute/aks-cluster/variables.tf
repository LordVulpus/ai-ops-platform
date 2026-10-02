# terraform/variables.tf (Global Inputs mapped exactly to live assets)

variable "resource_group_name" {
  type    = string
  default = "az-mothershipwest"
}

variable "location" {
  type    = string
  default = "ukwest"
}

# KEY VAULT & SECURITY NAMES
variable "keyvault_name" {
  type    = string
  default = "jf-mothership-keyvault"
}

variable "jumpbox_key_name" {
  type    = string
  default = "PortfolioJumpboxKey"
}

variable "central_computer_key_name" {
  type    = string
  default = "CentralComputerKey"
}

# STORAGE & REGISTRY NAMES
variable "storage_account_name" {
  type    = string
  default = "jfaiopsblob"
}

variable "container_registry_name" {
  type    = string
  default = "aiopsregistry15069"
}

# COMPUTE & CLUSTER NAMES
variable "jumpbox_vm_name" {
  type    = string
  default = "az-centralcomputer"
}

variable "aks_cluster_name" {
  type    = string
  default = "aiops-cluster"
}

# GLOBAL ACCOUNT METADATA
variable "subscription_id" {
  type    = string
  default = "c2c2dd70-d73d-413c-8083-87a6e41b02e8"
}

variable "tenant_id" {
  type    = string
  default = "e4817dd1-cf6e-4cc5-b76e-85d89aa6d3c2"
}
