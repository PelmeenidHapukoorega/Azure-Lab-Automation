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
