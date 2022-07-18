resource "azurerm_resource_group" "r-g" {
  name = "ds-rg"
  location = "westus"
}

data "azurerm_storage_account" "storage-account" {
  name = "storage1"
  resource_group_name = azurerm_resource_group.r-g.name
}

data "azurerm_virtual_machine" "vm" {
  name = "ds-vm"
  resource_group_name = azurerm_resource_group.r-g.name
}


resource "azurerm_monitor_diagnostic_setting" "diagnostic-setting" {
  name = "example"
  target_resource_id = data.azurerm_virtual_machine.vm.id
  storage_account_id = data.azurerm_storage_account.storage-account.id

  log {
    category = "AuditEvent"
    enabled = true

    retention_policy {
        days = 30
        enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
        days = 30
        enabled = true
    }
  }
}


