output "cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  description = "Resource group holding the cluster."
  value       = azurerm_resource_group.aks.name
}

output "node_resource_group" {
  description = "AKS-managed resource group holding node infrastructure."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "private_fqdn" {
  description = "Private API server FQDN; null when api_server_mode is public."
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL, used for workload identity federation."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
