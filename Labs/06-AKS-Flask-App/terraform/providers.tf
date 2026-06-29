terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name = "terraform-state-rg"
    storage_account_name = "sandertfstate"
    container_name = "tfstate"
    key = "lab06.terraform.tfstate"
  }

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 4.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.0"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false 
    }
  }
  subscription_id = var.subscription_id
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.main.kube_config[0].host
  client_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube.kube_config[0].cluster_ca_certificate)
}
