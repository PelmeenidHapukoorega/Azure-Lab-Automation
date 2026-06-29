variable "subscription_id" {
  description = "Azure Sub Id"
  type = string
}

variable "location" {
  description = "Azure region for resources"
  type = string
  default = "westeurope"
}

variable "prefix" {
  description = "Short prefix for naming resources"
  type = string
  default = "simplemetrics"
}

variable "vnet_address_space" {
  description = "Address space for VNet"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
  type = string
  default = "10.0.1.0/24"
}

variable "node_count" {
  description = "Initial number of nodes in the AKS cluster"
  type = number
  default = 2
}

variable "node_vm_size" {
  description = "VM size for AKS nodes. Tested available sizes in weseurope: Standard_D2as_v6, Standard_D2ads_v6, Standard_D2as_v7"
  type = string
  default = "Standard_D2as_v6"
}

variable "node_min_count" {
  description = "Min nr of nodes for autoscale"
  type = number
  default = 2
}

variable "node_max_count" {
  description = "Max nr of nodes for autoscale"
  type = number
  default = 5
}

variable "log_retention_days" {
  description = "Nr of days to retain logs in Log Analytics"
  type = number
  default = 30

}
variable "storage_replication" {
  description = "Replication type for ST account"
  type = string
  default = "ZRS"
}

variable "key_vault_sku" {
    description = "SKU for the key vault"
    type = string
    default = "standard"
}