data "azurerm_resource_group" "rg" {
    name = "pvt-ep-rg"  #rg created for private endpoint
}

data "azurerm_virtual_machine" "vm" {
  name = "pvtep-vm"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_log_analytics_workspace" "la-workspace" {
  name = "workspace1"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku = "standard"
  retention_in_days = 30
  daily_quota_gb = 1
  internet_ingestion_enabled = true
  internet_query_enabled = true
}

resource "azurerm_log_analytics_datasource_windows_event" "windows" {
  name = "lg-vm"
  resource_group_name = azurerm_resource_group.rg.name
  workspace_name = azurerm_log_analytics_workspace.la-workspace.name
  event_log_name = "system"  
  event_types = [ "error" ]
}


