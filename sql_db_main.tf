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
    sku_name = "S0"
    sample_name = "AdventureWorksLT"
    
}

