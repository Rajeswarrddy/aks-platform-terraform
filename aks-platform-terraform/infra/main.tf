locals {
  name_suffix = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      project     = var.project
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags
  )
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "./modules/network"

  name_suffix         = local.name_suffix
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.vnet_address_space
  aks_subnet_prefix   = var.aks_subnet_prefix
  tags                = local.common_tags
}

module "acr" {
  source = "./modules/acr"

  # ACR names must be globally unique, alphanumeric only.
  name                = replace("acr${var.project}${var.environment}", "-", "")
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = var.acr_sku
  tags                = local.common_tags
}

module "aks" {
  source = "./modules/aks"

  name_suffix         = local.name_suffix
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  kubernetes_version  = var.kubernetes_version
  subnet_id           = module.network.aks_subnet_id
  node_vm_size        = var.node_vm_size
  node_min_count      = var.node_min_count
  node_max_count      = var.node_max_count
  acr_id              = module.acr.id
  log_retention_days  = var.log_retention_days
  tags                = local.common_tags
}
