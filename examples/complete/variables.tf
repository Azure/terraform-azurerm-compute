variable "location" {
  type    = string
  default = "eastus"
}

variable "location_alt" {
  type    = string
  default = "eastus2"
}

variable "vm_os_simple_1" {
  type    = string
  default = "UbuntuServer"
}

variable "vm_os_simple_2" {
  type    = string
  default = "Debian"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type    = string
  default = "P@ssw0rd12345!"
}

variable "custom_data" {
  type    = string
  default = ""
}

variable "license_type" {
  type    = string
  default = "Windows_Client"
}

variable "identity_type" {
  type    = string
  default = "SystemAssigned"
}