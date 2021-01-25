variable "vm_os_simple" {
  default = ""
}

# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
variable "standard_os" {
  default = {
    "WindowsServer" = "MicrosoftWindowsServer,WindowsServer,2019-Datacenter"
  }
}
