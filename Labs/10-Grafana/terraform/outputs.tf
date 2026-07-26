output "endpoint" {
  description = "URI of Grafana"
  value = azurerm_dashboard_grafana.grafana.endpoint
}

output "id" {
  description = "ID of Grafana"
  value = azurerm_dashboard_grafana.grafana.id
}

output "log_analytics_workspace_id" {
  description = "ID of the log analytics workspace"
  value = data.azurerm_log_analytics_workspace.lab06.id
}