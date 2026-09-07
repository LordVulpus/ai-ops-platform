variable "prefix" {
  type        = string
  description = "Prefix for the AI Ops platform resources"
  default     = "az-centralcomputer"
}

variable "location" {
  type        = string
  description = "Primary Azure region"
  default     = "ukwest"
}
variable "ssh_public_key" {
  type        = string
  description = "The public SSH key used for VM authentication"
  sensitive   = true # Tells Terraform to hide this value in terminal outputs
}
