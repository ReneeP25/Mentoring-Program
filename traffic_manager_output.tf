
output "profile_id" {
    value = azurerm_traffic_manager_profile.traffic_manager.id
}

output "target_resource_id" {
    value = azurerm_public_ip.public_ip_address.id
}