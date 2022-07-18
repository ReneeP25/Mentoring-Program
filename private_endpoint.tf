resource "azurerm_resource_group" "rg" {
    name = "pvt-ep-rg"
    location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
    name = "pvt-ep-vnet"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = ["10.0.0.0/16"] 
}

resource "azurerm_subnet" "subnet1" {
  name = "pvt-ep-snet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
  enforce_private_link_service_network_policies = true
}

resource "azurerm_subnet" "subnet2" {
  name = "pvt-ep-snet2"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_public_ip" "public-ip" {
  name = "pvtep-ip"
  sku = "standard"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "static"
}

resource "azurerm_network_interface" "nic" {
  name = "pvtep-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name = "pvtep-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_F2"
  admin_username = "admin_name"
  admin_password = "P$wd@admin1"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku  = "2016-Datacenter"
    version = "latest"
  }
}

resource "azurerm_private_dns_zone" "dns-zone" {
    name = "pvt-ep-dns"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_endpoint" "pvt-ep" {
    name = "pvt-ep"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    subnet_id = azurerm_subnet.subnet2.id

    private_dns_zone_group {
      name = azurerm_private_dns_zone.dns-zone.name
      private_dns_zone_ids = azurerm_private_dns_zone.dns-zone.id
    }

    private_service_connection {
        name = "pvt-s1"
        is_manual_connection = true
        request_message = "pvt-ep is attempting to connect to remote resource"
    }
}