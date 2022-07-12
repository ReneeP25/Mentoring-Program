resource "azurerm_resource_group" "rg" {
    name = "container-rg"
    location = "eastus"
}

resource "azurerm_container_registry" "registry" {
    name = "acr-1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "basic"
    network_rule_bypass_option = "azureservices"
    public_network_access_enabled = false
    export_policy_enabled = false 
}

resource "azurerm_container_registry_task" "reg-task" {
    name = "acr-task"
    id = azurerm_container_registry.registry.id
    is_system_task = false
    enabled = true

    custom {
        login_server = azurerm_container_registry.login_server
        username = azurerm_container_registry.admin_username
        password = azurerm_container_registry.password
    }

    platform {
      os = "linux"
    }

    file_step {
      task_file_path = "yamlfile"
      context_path = "URL of source context"
    }
}

resource "azurerm_container_group" "container" {
    name = "aci-1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    os_type = "linux"
    ip_address_type = "public"
    dns_name_label = "aci-dns-lable"
    restart_policy = "onfailure"

    container {
      name = "container-1"
      image = "image.yml"
      cpu = "1"
      memory = "1.5"
    }

    image_registry_credential {
        login_server = azurerm_container_registry.login_server
        username = azurerm_container_registry.admin_username
        password = azurerm_container_registry.password
    }

    ports {
        port = 80
        protocol = "tcp"
    }
}
  
