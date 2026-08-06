variable "prefix" {
  description = "Naming for all resources within the RG"
  type = string
  default = "Log-OU"
}

variable "storage_prefix" {
  description = "Naming for ST account" /// Seperate variable here for ST account specifically becayse of naming constraints.
  type = string
  default = "logou"
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

variable "mysql_subnet_prefix" {
  description = "CIDR for MySQL flexible server delegated subnet"
  type = string
  default = "10.1.0.48/28"
}