resource "azurerm_log_analytics_workspace" "main" {
  name = "${var.prefix}-law"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku = "PerGB2018"
  retention_in_days = var.log_retention_days
}

resource "azurerm_monitor_action_group" "main" {
  name = "${var.prefix}-action-group"
  resource_group_name = azurerm_resource_group.main.name
  short_name = "simplealert"

  email_receiver {
    name = "Mooses"
    email_address = "moosessander@gmail.com"
  }
}

resource "azurerm_monitor_metric_alert" "node_cpu" {
  name = "${var.prefix}-node_cpu_alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes = [azurerm_kubernetes_cluster.main.id]
  description = "Alert when node CPU exceeds 80%"
  severity = 2
  frequency = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name = "node_cpu_usage_percentage"
    aggregation = "Average"
    operator = "GreaterThan"
    threshold = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_metric_alert" "node_memory" {
  name = "${var.prefix}-node-memory-Alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes = [azurerm_kubernetes_cluster.main.id]
  description = "Alert when node memory exceeds 80%"
  severity = 2
  frequency = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name = "node_memory_rss_percentage"
    aggregation = "Average"
    operator = "GreaterThan"
    threshold = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}