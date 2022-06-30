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

