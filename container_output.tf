output "login_server" {
    value = azurerm_container_registry.registry.login_server
}

output "admin_username" {
    value = azurerm_container_registry.registry.admin_username
}

output "admin_password" {
    value = azurerm_container_registry.registry.admin_password
}

output "fqdn" {
    value = azurerm_container_registry_task.reg-task.dns_name_label.fqdn
}

output "ip_address" {
    value = azurerm_container_group.container.ip_address
}