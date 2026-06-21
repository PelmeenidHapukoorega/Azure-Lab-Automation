variable "subscription_id" {
  description = "Azure subscription ID to deploy resources into"
  type = string
}

variable "location" {
  description = "Azure region for all resources"
  type = string
  default = "westeurope"
}

variable "prefix" {
  description = "Short prefix for naming resources"
  type = string
  default = "tf-foundation"
}

variable "vm-admin-username" {
  description = "Admin username for the VMs"
  type = string
  default = "azureadmin"
}