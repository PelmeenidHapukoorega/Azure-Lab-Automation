resource "azurerm_kubernetes_cluster" "main" {
  name = "${var.prefix}-aks"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix = var.prefix

  default_node_pool {
    name = "system"
    node_count = var.node_count
    vm_size = var.node_vm_size
    zones = ["1", "2", "3"]
    auto_scaling_enabled = true
    min_count = var.node_min_count
    max_count = var.node_max_count
    vnet_subnet_id = azurerm_subnet.main.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    service_cidr = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  monitor_metrics {}

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  ingress_application_gateway {
    gateway_name = "${var.prefix}-agw"
    subnet_cidr = "10.0.2.0/24"
  }
}

