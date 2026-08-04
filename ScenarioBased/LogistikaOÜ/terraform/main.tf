terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name = "terraform-state-rg"
    storage_account_name = "sandertfstate"
    container_name = "tfstate"
    key = "logistikaou.terraform.tfstate"
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

resource "azurerm_resource_group" "LogistikaOU" {
  name = "${var.prefix}-rg"
  location = var.location
}