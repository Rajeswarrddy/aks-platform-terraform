variable "environment" {
  description = "Environment name (dev, test, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westus2"
}

variable "project" {
  description = "Short project name used in resource names."
  type        = string
  default     = "aksplat"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "aks_subnet_prefix" {
  description = "CIDR for the AKS node subnet."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Leave null to use the region default."
  type        = string
  default     = null
}

variable "node_vm_size" {
  description = "VM size for the default node pool."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "node_min_count" {
  description = "Minimum nodes for the autoscaler."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum nodes for the autoscaler."
  type        = number
  default     = 3
}

variable "acr_sku" {
  description = "Container registry SKU (Basic, Standard, Premium)."
  type        = string
  default     = "Basic"
}

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
