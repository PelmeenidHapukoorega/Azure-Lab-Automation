variable "prefix" {
  description = "Naming for all resources within the RG"
  type = string
  default = "Log-OU"
}

variable "location" {
  description = "Region/Location where resources exist"
  type = string
  default = "westeurope"
}

variable "subscription_id" {
  description = "Subscription ID"
  type = string
}

variable "mysql_admin_username" {
  description = "MySQL admin username"
  type = string
  sensitive = true
}

variable "mysql_admin_password" {
  description = "MySQL admin password"
  type = string
  sensitive = true
}

variable "vnet_address_space" {
  description = "address space for the Logistika Vnet"
  type = string
  default = "10.1.0.0/24"
}

variable "appservice_subnet_prefix" {
  description = "Appservice vnet integration subnet"
  type = string
  default = "10.1.0.0/27"
}

variable "pe_subnet_prefix" {
  description = "shared endpoints subnet (MySql, Storage and key vault)"
  type = string
  default = "10.1.0.32/28"
}