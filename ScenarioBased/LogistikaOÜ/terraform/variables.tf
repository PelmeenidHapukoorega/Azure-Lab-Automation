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