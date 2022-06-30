resource "azurerm_resource_group" "resource_group"{
    name = var.rgname
    location = var.location
}

resource "azurerm_public_ip" "public_ip_address"{
    name = var.publicip
    location = azurerm_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name
    allocation_method = var.allocation_method
}

resource "azurerm_traffic_manager_profile" "traffic_manager" {
    name = var.traffic_mng
    resource_group_name = azurerm_resource_group.resource_group.name
    traffic_routing_method = "priority"

    dns_config {
      relative_name = "traffic-profile-dns"
      ttl = 100
    }

    monitor_config {
      protocol = "TCP"
      port = 80
      interval_in_seconds = 30
      tolerated_number_of_failures = 2
      timeout_in_seconds = 10
       expected_status_code_ranges = 200 - 299
    }

    traffic_view_enabled = true
    
}

resource "azurerm_traffic_manager_azure_endpoint" "traffic_manager_endpoint" {
  name = var.traffic_endpoint
  profile_id = azurerm_traffic_manager_profile.traffic_manager.id
  weight = 200
  target_resource_id = azurerm_public_ip.public_ip_address.id  
  priority = 1
}
