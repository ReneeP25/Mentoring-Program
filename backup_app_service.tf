resource "azurerm_resource_group" "rg" {
    name = "app-rg"
    location = "eastus"
}

resource "azurerm_storage_account" "storage" {
    name = "storage-acc"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

}

resource "azurerm_service_plan" "app-service" {
    name = "plan-app"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    os_type = windows
    sku_name = "p1v2"
}

resource "azurerm_windows_web_app" "app" {
    name = "app1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    service_plan_id = azurerm_service_plan.app-service.id

    auth_settings {
      enabled = true 
      default_provider = "AzureActiveDirectory"
    }

    backup {
      name = "app1-backup"  
      storage_account_url = ""
      schedule {
        frequency_interval = 7
        frequency_unit = "day"
        keep_at_least_one_backup = false 
        retention_period_days = 90
      }
      enabled = true
    }
}