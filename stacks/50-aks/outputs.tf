output "cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.cluster_name
}

output "resource_group_name" {
  description = "Resource group holding the cluster."
  value       = module.aks.resource_group_name
}

output "private_fqdn" {
  description = "Private API server FQDN."
  value       = module.aks.private_fqdn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity."
  value       = module.aks.oidc_issuer_url
}
