output "resource_group_name" {
  description = "Name of the RG"
  value = azurerm_resource_group.this
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value = azurerm_kubernetes_cluster.DeepK8s
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.DeepK8s.kube_config_raw
  sensitive = true
}