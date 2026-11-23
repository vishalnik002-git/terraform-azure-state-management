# Sample resource for demonstrating state management, drift detection, and state inspection
resource "azurerm_resource_group" "workload" {
  name     = var.workload_resource_group_name
  location = var.location
}
