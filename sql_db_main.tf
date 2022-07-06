#Azure SQL - single DB

resource "azurerm_resource_group" "resource-group" {
    name = "sql_db_rg"
    location = "westus"  
}

resource "azurerm_mssql_server" "sql-server" {
    name = "db_server"
    location = azurerm_resource_group.resource-group.location
    resource_group_name = azurerm_resource_group.resource-group.name
    version = "12.0"
    administrator_login = "sqladmin"
    administrator_login_password = "#Sql1Passwd"
}

resource "azurerm_mssql_database" "database" {
    name = "db1"
    server_id = azurerm_mssql_server.sql-server.id
    max_size_gb = 7
    sku_name = "basic"
    sample_name = "AdventureWorksLT"
    create_mode = "pointintimerestore"
    restore_point_in_time = "2022-07-06T15:49:20.000Z"
    zone_redundant = true
    license_type = "licenseincluded"
    geo_backup_enabled = false

    short_term_retention_policy {
      retention_days = 14
      back_up_interval_in_hours = 12
    }

}


