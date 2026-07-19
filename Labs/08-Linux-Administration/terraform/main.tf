terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name = "terraform-state-rg"
    storage_account_name = "sandertfstate"
    container_name = "tfstate"
    key = "lab08.terraform.tfstate"
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

module "networking" {
  source = "git::https://github.com/PelmeenidHapukoorega/Deployment-templates.git//terraform/modules/networking?ref=9733a99"

  prefix = var.prefix
  location = var.location
  resource_group_name = azurerm_resource_group.this.name
  management_allowed_cidr = "194.150.65.93/32"
  subnets = [
    { name = "default", address_prefixes = ["10.0.1.0/24"] }
  ]
}