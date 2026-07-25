variable "prefix" {
  description = "naming prefix for all resources"
  type = string
  default = "lab10"
}

variable "location" {
    description = "Region to deploy into"
    type = string
    default = "westeurope"
}

variable "subscription_id" {
  description = "AZ subscription ID"
  type = string
}

variable "ssh_public_key" {
  description = "SSH public key for the VM admin"
  type = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type = string
  default = "azureuser"
}