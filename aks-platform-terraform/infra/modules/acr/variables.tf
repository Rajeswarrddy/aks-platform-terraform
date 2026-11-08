variable "name" {
  description = "Registry name (globally unique, alphanumeric, 5-50 chars)."
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

variable "sku" {
  description = "Registry SKU: Basic, Standard or Premium."
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
