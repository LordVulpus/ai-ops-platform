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
