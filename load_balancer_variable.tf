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
    default = "static"
}

variable "lb" {
    default = "loadbalancer1"
  
}

variable "sku" {
    default = "basic"
}

variable "frontend_config" {
    default = "frontend_ip_address"
  
}

