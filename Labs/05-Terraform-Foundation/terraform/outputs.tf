output "resource_group_name" {
  description = "Name of RG"
  value = azurerm_resource_group.main.name
}

output "vnet_name" {
  description = "Name of the VNet"
  value = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "ID of Subnet"
  value = azurerm_subnet.main.id
}

output "nsg_name" {
  description = "Name of NSG"
  value = azurerm_network_security_group.main.name
}

output "storage_account_name" {
  description = "Name of ST account"
  value = azurerm_storage_account.main.name
}

output "vm_private_ip" {
  description = "Private IP of VM"
  value = azurerm_linux_virtual_machine.main.private_ip_address
}