#ressource group
resource "azurerm_resource_group" "rg" {
    name = "s2s_resource_group"
    location = "westus"
}

#vnet
resource "azurerm_virtual_network" "vnet" {
    name = "s2s_vnet"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = ["10.0.0.0/16"]
}

#subnet
resource "azurerm_subnet" "subnet" {
    name = "s2s_subnet"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix = ["10.0.1.0/24"]
}

#nat gateway
resource "azurerm_nat_gateway" "nat_gw" {
  name                = "s2s-natgateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_nat_gateway_association" "subnet_nat" {
  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}


    
#local_network_gateway
resource "azurerm_local_network_gateway" "lng" {
    name = "s2s_lng"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = ["192.168.1.0/24"]
}

#public IP
resource "azurerm_public_ip" "publicIP" {
    name = "s2s_public_ip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "static" 
}

#vnet gateway
resource "azurerm_virtual_network_gateway" "vnet_gateway" {
  name                = "s2s_vnet_gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  
  type     = "vpn"
  vpn_type = "routebased"

  active_active = false
  enable_bgp    = false
  sku           = "basic"

  ip_configuration {
    name                          = "vnet_gateway_config"
    public_ip_address_id          = azurerm_public_ip.publicIP.id
    subnet_id                     = azurerm_subnet.subnet.id
  }
}

#connection
resource "azurerm_virtual_network_gateway_connection" "connection" {
  name                = "s2s_coonection"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                       = "ipsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.lng.id
  shared_key = "s2s_password"
}

#network interface
resource "azurerm_network_interface" "nic" {
  name                = "s2s_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic_ip"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "static"
  }
}

#virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "s2s_vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "standard_f2"
  admin_username      = "s2s_user"
  admin_password      = "#Password2"
  network_interface_ids = [
    azurerm_network_interface.nic.id, 
    ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}