output "workload_rg_id" {
  description = "ID of the tracked workload Resource Group."
  value       = azurerm_resource_group.workload.id
}

output "workload_rg_name" {
  description = "Name of the tracked workload Resource Group."
  value       = azurerm_resource_group.workload.name
}
