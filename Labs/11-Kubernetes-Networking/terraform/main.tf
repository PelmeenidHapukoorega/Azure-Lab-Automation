terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name = "terraform-state-rg"
    storage_account_name = "sandertfstate"
    container_name = "tfstate"
    key = "lab11.terraform.tfstate"
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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false 
    }
  }
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "this" {
  name = "${var.prefix}-rg"
  location = var.location
}

module "networking" {
  source = "git::https://github.com/PelmeenidHapukoorega/Deployment-templates.git//terraform/modules/networking?ref=9733a99"

  prefix = var.prefix
  location = var.location
  resource_group_name = azurerm_resource_group.this.name
  management_allowed_cidr = null
  subnets = [
    { name = "aks-nodes", address_prefixes = ["10.0.1.0/24"] }
  ]
}

resource "azurerm_kubernetes_cluster" "DeepK8s" {
  name = "${var.prefix}-aks1"
  location = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix = "testingAks1"

  default_node_pool {
    name = "pool1"
    node_count = "${var.node_count}"
    vm_size = "${var.node_vm_size}"
    vnet_subnet_id = module.networking.subnet_ids["aks-nodes"]
    min_count = var.node_min_count
    max_count = var.node_max_count
    auto_scaling_enabled = true
  }

  network_profile {
    network_plugin = "azure"
    service_cidr = "10.100.0.0/16"
    dns_service_ip = "10.100.0.10"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  } 
}
