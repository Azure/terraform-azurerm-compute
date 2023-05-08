variable "admin_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "custom_data" {
  type    = string
  default = ""
}

variable "key_vault_firewall_bypass_ip_cidr" {
  type    = string
  default = null
}

variable "license_type" {
  type    = string
  default = "Windows_Client"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "location_alt" {
  type    = string
  default = "eastus2"
}

variable "managed_identity_principal_id" {
  type    = string
  default = null
}

variable "vm_os_simple_1" {
  type    = string
  default = "UbuntuServer"
}

variable "vm_os_simple_2" {
  type    = string
  default = "Debian"
}
