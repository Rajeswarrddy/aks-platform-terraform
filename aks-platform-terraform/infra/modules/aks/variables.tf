variable "name_suffix" {
  description = "Suffix used in resource names, e.g. aksplat-dev."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version. Null uses the region default."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for the node pool."
  type        = string
}

variable "node_vm_size" {
  description = "VM size for the default node pool."
  type        = string
}

variable "node_min_count" {
  description = "Autoscaler minimum node count."
  type        = number
}

variable "node_max_count" {
  description = "Autoscaler maximum node count."
  type        = number
}

variable "acr_id" {
  description = "Container registry ID to grant AcrPull on."
  type        = string
}

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
