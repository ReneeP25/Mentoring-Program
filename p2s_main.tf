#resource group
resource "azurerm_resource_group" "resource_group" {
    name = "p2s_resource_group"
    location = "westus"
}

#vnet
resource "azurerm_virtual_network" "vnet" {
    name = "p2s_vnet"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = azurerm_resource_group.resource_group.location
    address_space = ["10.0.0.0/16"]
}

#subnet
resource "azurerm_subnet" "subnet" {
    name = "p2s_subnet"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = azurerm_resource_group.resource_group.location
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix = ["10.0.1.0/24"]
}

#nat gateway
resource "azurerm_nat_gateway" "nat_gw" {
  name                = "p2s-natgateway"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet_nat_gateway_association" "subnet_nat" {
  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

#public IP
resource "azurerm_public_ip" "publicIP" {
    name = "p2s_public_ip"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = azurerm_resource_group.resource_group.location
    allocation_method = "static" 
}

#vnet gateway
resource "azurerm_virtual_network_gateway" "vnet_gateway" {
  name                = "p2s_vnet_gateway"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location

  type     = "vpn"
  vpn_type = "routebased"
  generation = "generation1"
  
  active_active = false
  enable_bgp    = false
  sku           = "basic"

  ip_configuration {
    name                          = "vnet_gateway_config"
    public_ip_address_id          = azurerm_public_ip.publicIP.id
    subnet_id                     = azurerm_subnet.subnet.id
  }
}

resource "azurerm_vpn_server_configuration" "vpn_config" {
  name                     = "p2s_vpn_config"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  vpn_authentication_types = ["Certificate"]

  client_root_certificate {
    name             = "DigiCert-Federated-ID-Root-CA"
    #root certificate for authentication
    #to copy public cert data from root certificate file
    public_cert_data = <<EOF
MIIDuzCCAqOgAwIBAgIQCHTZWCM+IlfFIRXIvyKSrjANBgkqhkiG9w0BAQsFADBn

M/s/1JRtO3bDSzD9TazRVzn2oBqzSa8VgIo5C1nOnoAKJTlsClJKvIhnRlaLQqk=
EOF
  }
}

#network interface
resource "azurerm_network_interface" "nic" {
  name                = "p2s_nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "nic_ip"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "static"
  }
}

#virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "p2s_vm"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "standard_f2"
  admin_username      = "p2s_user"
  admin_password      = "#Password4"
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