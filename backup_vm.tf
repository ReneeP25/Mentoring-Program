resource "azurerm_resource_group" "r-g" {
    name = "vm-rg"
    location = "eastus"
}

resource "azurerm_recovery_services_vault" "rsv" {
    name = "vm-rsv"
    resource_group_name = azurerm_resource_group.r-g.name
    location = azurerm_resource_group.r-g.location
    sku = "standard"
    storage_mode_type = "zoneredundant"
    cross_region_restore_enabled = false 
    soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "backup-policy" {
    name = "vm-policy"
    resource_group_name = azurerm_resource_group.r-g.name
    recovery_vault_name = azurerm_recovery_services_vault.rsv.name
    policy_type = "v1"
    timezone = "utc"
    instant_restore_retention_days = 4

    backup {
      frequency = "daily"
      time = "20:00:00"
    }

    retention_daily {
      count = 8
    }

    retention_weekly {
      count = 12
      weekdays = [ "saturday" ]
    }

    retention_monthly {
      count = 96   
      weekdays = ["saturday"]
      weeks = [ "last" ]
    }

    retention_yearly {
      count = 1152
      weekdays = [ "saturday" ]
      weeks = [ "last" ]
      months = [ "december" ]
    }
}

data "azurerm_virtual_machine" "vm" {
    name = "vm-backup"
    resource_group_name = azurerm_resource_group.r-g.name
}

resource "azurerm_backup_protected_vm" "backup-vm" {
    resource_group_name = azurerm_resource_group.r-g.name
    recovery_vault_name = azurerm_recovery_services_vault.rsv.name
    source_vm_id = data.azurerm_virtual_machine.vm.id
    backup_policy_id = azurerm_backup_policy_vm.backup-policy.id
}