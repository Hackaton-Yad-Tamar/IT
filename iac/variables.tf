variable "resource_group_location" {
  type        = string
  default     = "West Europe"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "inbound_port_ranges" {
  type        = list
  default     = ["22", "8080", "443", "5432", "9100", "9090", "9187"]
  description = "the VM nsg port ranges"
}
