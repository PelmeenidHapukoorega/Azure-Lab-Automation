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
    subnet_id = module.networking.subnet_ids["default"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.this.id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name = "${var.prefix}-vm"
  location = var.location
  resource_group_name = azurerm_resource_group.this.name
  size = "Standard_D2as_v6"
  admin_username = var.admin_username

  network_interface_ids = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
    version = "latest"
  }
}