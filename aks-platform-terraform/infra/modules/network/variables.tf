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

variable "address_space" {
  description = "VNet address space."
  type        = list(string)
}

variable "aks_subnet_prefix" {
  description = "CIDR for the AKS subnet."
  type        = string
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
