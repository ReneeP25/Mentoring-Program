resource "azurerm_resource_group" "resource-group" {
    name = "monitor-rg"
    location = "eastus"
}

resource "azurerm_storage_account" "storage" {
    name = "monitor-storage"
    resource_group_name = azurerm_resource_group.resource_group_name.name  
    location = azurerm_resource_group.resource-group.location
    account_kind = "storagev2"
    account_replication_type = "ZRS"
    access_tier = "hot"
    shared_access_key_enabled = true
}

resource "azurerm_monitor_action_group" "action" {
    name = "file-size-monitor"
    resource_group_name = azurerm_resource_group.resource-group.name
    short_name = "file"

    email_receiver {
        name = "user1"
        email_address = "user1@domain.com"
        use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "alert" {
    name = "file-alert"
    resource_group_name = azurerm_resource_group.resource-group.name
    scopes = [azurerm_storage_account.to_monitor.id]
    description = "To send mail to user1 when the size of file in azure account is greater than 200MB"
    enabled = true
    auto_mitigate = true
    frequency = "PT5M"
    severity = 3
    target_resource_type = "Microsoft./"
    target_resource_location = azurerm_resource_group.resource-group.location

    action {
      action_group_id = azurerm_monitor_action_group.action.id
    }

    criteria {
      metric_namespace = "Microsoft.Storage/storageAccounts"
      metric_name = "File Size"
      aggregation = "Size"
      operator = "Greater Than"
      threshold = 200
    }
}