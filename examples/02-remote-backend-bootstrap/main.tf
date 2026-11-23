# Bootstrap infrastructure to host remote Terraform state files
# 1. Dedicated Resource Group for backend
resource "azurerm_resource_group" "backend_rg" {
  name     = var.backend_rg_name
  location = var.location
}

# 2. Secure Storage Account for state storage
resource "azurerm_storage_account" "backend_sa" {
  name                     = var.backend_storage_name
  resource_group_name      = azurerm_resource_group.backend_rg.name
  location                 = azurerm_resource_group.backend_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# 3. Blob Container for holding state blobs
resource "azurerm_storage_container" "tfstate_container" {
  name                  = var.backend_container_name
  storage_account_name  = azurerm_storage_account.backend_sa.name
  container_access_type = "private"
}
