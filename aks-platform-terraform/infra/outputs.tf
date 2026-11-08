output "resource_group_name" {
  description = "Resource group containing the platform."
  value       = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.cluster_name
}

output "acr_login_server" {
  description = "ACR login server (use for docker push)."
  value       = module.acr.login_server
}

output "get_credentials_command" {
  description = "Command to fetch kubeconfig for this cluster."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${module.aks.cluster_name}"
}
