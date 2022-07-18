resource "azurerm_resource_group" "rg" {
    name = "domain-rg"
    location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
    name = "domain-vnet"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = ["10.0.0.0/16"] 
}

resource "azurerm_subnet" "subnet" {
  name = "domain-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public-ip" {
  name = "domain-ip"
  sku = "standard"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "static"
}

resource "azurerm_network_interface" "nic" {
  name = "domain-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
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

resource "azurerm_virtual_machine_extension" "vm-join" {
    name = "vm-ext"
    virtual_machine_id = azurerm_windows_virtual_machine.vm.id
    publisher = "Microsoft.Azure.Extensions"
    type = "customscript"
    type_handler_version = "2.0"
    automatic_upgrade_enabled = false
}
