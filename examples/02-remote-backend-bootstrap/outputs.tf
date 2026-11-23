output "backend_resource_group" {
  value = azurerm_resource_group.backend_rg.name
}

output "backend_storage_account" {
  value = azurerm_storage_account.backend_sa.name
}

output "backend_container" {
  value = azurerm_storage_container.tfstate_container.name
}
