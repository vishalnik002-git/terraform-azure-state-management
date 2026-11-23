variable "workload_resource_group_name" {
  type        = string
  description = "The Resource Group name for state management workload."
  default     = "rg-state-governance-dev"
}

variable "location" {
  type        = string
  description = "Azure region for resource placement."
  default     = "eastus"
}
