variable "prefix" {
  type        = string
  description = "A prefix for all resources to ensure unique naming (e.g., dev, prod, portfolio)"
  default     = "az-centralcomputer"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
  default     = "UK West"
}

variable "vnet_cidr" {
  type        = string
  description = "The address space for the VNet"
  default     = "10.0.0.0/16"
}
