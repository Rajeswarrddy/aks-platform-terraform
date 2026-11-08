resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Pull access is granted to AKS through a role assignment, not admin creds.
  admin_enabled = false

  tags = var.tags
}
