terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name = "terraform-state-rg"
    storage_account_name = "sandertfstate"
    container_name = "tfstate"
    key = "lab10.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "this" {
  name = "${var.prefix}-rg"
  location = var.location
}

data "azurerm_log_analytics_workspace" "lab06" {
  name = "simplemetrics-law"
  resource_group_name = "simplemetrics-rg"
}

resource "azurerm_dashboard_grafana" "grafana" {
  name = "${var.prefix}-test"
  resource_group_name = azurerm_resource_group.this.name
  location = var.location
  grafana_major_version = 12
  api_key_enabled = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled = true
  sku = "Standard"
  sku_size = "X1"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
    Project = "Lab10-Grafana"
  }
}

resource "azurerm_role_assignment" "MonitoringReader" {
  scope = data.azurerm_log_analytics_workspace.lab06.id
  role_definition_name = "Monitoring Reader"
  principal_id = azurerm_dashboard_grafana.grafana.identity[0].principal_id
}