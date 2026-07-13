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
}