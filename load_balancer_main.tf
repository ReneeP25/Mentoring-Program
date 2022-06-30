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

resource "azurerm_lb" "load_balancer"{
  name = var.lb
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku = var.sku

  frontend_ip_configuration {
    name = var.frontend_config
    public_ip_address_id = azurerm_public_ip.public_ip_address.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name = var.backendpoolname
  loadbalancer_id = azurerm_lb.load_balancer.id
}

resource "azurerm_lb_nat_rule" "nat_rule" {
  name = var.nat_rule_name
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id = azurerm_lb.load_balancer.id
  protocol = "TCP"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = azurerm_lb.load_balancer.frontend_ip_configuration.name
  idle_timeout_in_minutes = 4
}  

resource "azurerm_lb_probe" "healthprobe" {
  name = var.probename
  loadbalancer_id = azurerm_lb.load_balancer.id
  protocol = "TCP"
  port = 80  
}