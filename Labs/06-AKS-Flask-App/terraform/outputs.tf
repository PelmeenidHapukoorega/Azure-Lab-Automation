output "resource_group_name" {
  description = "Name of the RG"
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value = azurerm_kubernetes_cluster.main.name
}

output "acr_login_server" {
  description = "Login server URL for container registry"
  value = azurerm_container_registry.main.login_server
}

output "log_analytics_workspace_id" {
  description = "ID of the log analytics workspace"
  value = azurerm_log_analytics_workspace.main.id
}

output "key_vault_uri" {
  description = "URI of the key vault"
  value = azurerm_key_vault.main.vault_uri
}

output "kube_config" {
  description = "Kubernetes config for kubectl"
  value = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}