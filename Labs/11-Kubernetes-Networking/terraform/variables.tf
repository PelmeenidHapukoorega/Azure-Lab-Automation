variable "prefix" {
  description = "Naming for resources"
  type = string
  default = "k8sNet"
}

variable "location" {
  description = "Region where resources would be deployed"
  type = string
  default = "westeurope"
}

variable "subscription_id" {
  description = "subscription ID"
  type = string
}

variable "node_count" {
  description = "Node count for AKS"
  type = string
  default = "3"
}

variable "node_min_count" {
  description = "Minimum node count at start"
  type = string
  default = "2"
}

variable "node_max_count" {
  description = "Maximum node count it can scale to"
  type = string
  default = "6"
}

variable "node_vm_size" {
  description = "Node VM size"
  type = string
  default = "Standard_D2as_v6"
}
