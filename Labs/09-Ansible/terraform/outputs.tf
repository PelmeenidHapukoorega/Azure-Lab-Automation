output "public_ip_address" {
  description = "VMs public IP"
  value = azurerm_public_ip.this.ip_address
}

output "vm_id" {
  description = "VMs resource ID"
  value = azurerm_linux_virtual_machine.this.id
}

output "ssh_command" {
  description = "Command to ssh into vm"
  value = "ssh ${var.admin_username}@${azurerm_public_ip.this.ip_address}"
}