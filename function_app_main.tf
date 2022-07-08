resource "azurerm_resource_group" "r-g" {
    name = "function-rg"
    location = "westus"
}

resource "azurerm_storage_account" "storage-account" {
    name = "function-sa"
    resource_group_name = azurerm_resource_group.r-g.name
    location = azurerm_resource_group.r-g.location
    access_tier = "basic"
    account_kind = "storagev2"
    account_replication_type = "grs"
    account_tier = "hot"
    shared_access_key_enabled = true
}

resource "azurerm_service_plan" "service-plan" {
    name = "function-service-plan"
    resource_group_name = azurerm_resource_group.r-g.name
    location = azurerm_resource_group.r-g.location
    os_type = "linux"
    sku_name = "B1"
}

resource "azurerm_linux_function_app" "function-app" {
    name = "function-app-1"
    resource_group_name = azurerm_resource_group.r-g.name
    location = azurerm_resource_group.r-g.location
    storage_account_name = azurerm_storage_account.storage-account.name
     storage_account_access_key = azurerm_storage_account.storage-account.primary_access_key
    service_plan_id = azurerm_service_plan.service-plan.id
    enabled = true
    content_share_force_disabled = false
    site_config {
      always_on = false
      load_balancing_mode = "leastrequests"
      use_32_bit_worker = true
    }
}

resource "azurerm_function_app_function" "function" {
  name            = "function1"
  function_app_id = azurerm_linux_function_app.function-app.id
  language        = "python"

  file {
    name    = "reminder.py"
    content = file("C:/Users/seles_r/Desktop/New folder/task4/reminder.py")
  }

  test_data = jsonencode({
    "name" = "Azure"
  })

  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })

}
