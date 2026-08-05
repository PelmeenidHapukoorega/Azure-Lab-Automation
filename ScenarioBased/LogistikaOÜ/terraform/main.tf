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

resource "azurerm_virtual_network" "main" {
  name = "${var.prefix}-vnet"
  address_space = [var.vnet_address_space]
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
}

resource "azurerm_subnet" "appservice" {
  name = "${var.prefix}-snet-appservice"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [var.appservice_subnet_prefix]

  delegation {
    name = "appservice-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private-endpoints" {
  name = "${var.prefix}-snet-pe"
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [var.pe_subnet_prefix]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_network_security_group" "PE-nsg" {
  name = "${var.prefix}-nsg-pe"
  location = azurerm_resource_group.LogistikaOU.location
  resource_group_name = azurerm_resource_group.LogistikaOU.name
}

resource "azurerm_network_security_rule" "Inbound-MySQL" {
  name = "Allow-MySQL"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3306"
  source_address_prefix = var.appservice_subnet_prefix /// AppService
  destination_address_prefix = var.pe_subnet_prefix /// Private endpoint subnet
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  network_security_group_name = azurerm_network_security_group.PE-nsg.name
}

resource "azurerm_network_security_rule" "Inbound-AzureFiles" {
  name = "AllowAz-Files"
  priority = 200
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "445"
  source_address_prefix = var.appservice_subnet_prefix /// AppService
  destination_address_prefix = var.pe_subnet_prefix ///Private endpoint subnet
  resource_group_name = azurerm_resource_group.LogistikaOU.name
  network_security_group_name = azurerm_network_security_group.PE-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "pe-subn-nsg-assoc" {
  subnet_id = azurerm_subnet.private-endpoints.id
  network_security_group_id = azurerm_network_security_group.PE-nsg.id
}