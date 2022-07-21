resource "azurerm_resource_group" "r_g" {
    name = "sql-rg"
    location = "eastus"
}

resource "azurerm_storage_account" "storage" {
    name = "storage-acc"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    access_tier = "standard"
}

resource "azurerm_storage_container" "container" {
  name                  = "container1"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "blob1.zip"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "block"
  source                 = "file.zip"
}

data "azurerm_virtual_machine" "vm" {
    name = "sql-vm"
    resource_group_name = azurerm_resource_group.r_g.name
}

resource "azurerm_mssql_virtual_machine" "ms-sql-vm" {
    virtual_machine_id = data.azurerm_virtual_machine.vm.id
    sql_license_type = "payg"
    r_services_enabled = true 
    sql_connectivity_port = 1433
    sql_connectivity_type = "private"
    sql_connectivity_update_username = "admin_user"
    sql_connectivity_update_password = "Pswd!123"

    auto_backup {
      encryption_enabled = false 
      retention_period_in_days = 28
      storage_blob_endpoint = azurerm_storage_blob.blob.id
      storage_account_access_key = azurerm_storage_account.storage.primary_access_key
      system_databases_backup_enabled = false
    }
  
}