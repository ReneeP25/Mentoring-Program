variable "rgname" {
  default = "resource_group1"
}

variable "location" {
    default = "eastus"
}

variable "publicip" {
    default = "public_ip1" 
}

variable "allocation_method" {
    default = "Static"
}

variable "lb" {
    default = "loadbalancer1"
  
}

variable "sku" {
    default = "Basic"
}

variable "frontend_config" {
    default = "frontend_ip_address"
  
}

