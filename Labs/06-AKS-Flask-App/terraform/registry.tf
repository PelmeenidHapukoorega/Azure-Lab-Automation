resource "azurerm_container_registry" "main" {
  name = "${replace(var.prefix, "-", "")}registry"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  sku = "Basic"
  admin_enabled = false
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "agic_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}