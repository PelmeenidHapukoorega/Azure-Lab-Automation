resource "azurerm_storage_account" "main" {
  name = "${replace(var.prefix, "-", "")}logs"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  account_tier = "Standard"
  account_replication_type = var.storage_replication
  min_tls_version = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name = "${var.prefix}-aks-diag"
  target_resource_id = azurerm_kubernetes_cluster.main.id
  storage_account_id = azurerm_storage_account.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}