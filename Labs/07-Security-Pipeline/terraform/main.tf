terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription.id
}

resource "azurerm_resource_group" "this" {
  name = "${var.prefix}-rg"
  location = var.location
}

module "networking" {
  source = "git::https://github.com/PelmeenidHapukoorega/azure-deployment-templates.git//terraform/modules/networking?ref=main"

  prefix = var.prefix
  location = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnets = [
    { name = "default", address_prefixes = ["10.0.1.0/24"] }
  ]
}

resource "azurerm_public_ip" "this" {
  name = "${var.prefix}-pip"
  location = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_network_interface" "this" {
  name = "${var.prefix}-nic"
  location = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name = "internal"
    subnet_id = module/networking.subnet_ids["default"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.this.id
  }
}