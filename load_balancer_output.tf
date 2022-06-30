output "public_ip_address_id" {
    value = azurerm_public_ip.public_ip_address.id
}

output "loadbalancer_id" {
    value = azurerm_lb.load_balancer.id
}