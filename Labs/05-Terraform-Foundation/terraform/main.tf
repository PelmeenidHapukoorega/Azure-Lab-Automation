resource "azurerm_resource_group" "main" {
  name = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name = "${var.prefix}-vnet"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main" {
  name = "${var.prefix}-subnet"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name = "${var.prefix}-nsg"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name = "Allow-SSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    }

  security_rule {
    name = "Allow-HTTP"
    priority = 200
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Deny-All-Inbound"
    priority = 4096
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix ="*"
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_storage_account" "main" {
  name = "tfoundation${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  min_tls_version = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

resource "random_string" "suffix" {
  length = 6
  special = false
  upper = false
}

resource "azurerm_network_interface" "main" {
  name = "${var.prefix}-nic"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  size = "Standard_D2as_v6"
  admin_username = var.vm-admin-username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  admin_ssh_key {
    username = var.vm-admin-username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-focal"
    sku = "20_04-lts-gen2"
    version = "latest"
  }
}