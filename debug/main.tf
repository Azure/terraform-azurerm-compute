variable "nb_instances" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "data_disk" {
  type        = string
  description = "Set to true to add a datadisk."
  default     = "false"
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  default     = "false"
}

variable "vm_os_simple" {
  default = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = "WindowsServer"
}

# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
variable "standard_os" {
  default = {
    "UbuntuServer"  = "Canonical,UbuntuServer,16.04-LTS"
    "WindowsServer" = "MicrosoftWindowsServer,WindowsServer,2016-Datacenter"
    "RHEL"          = "RedHat,RHEL,7.5"
    "openSUSE-Leap" = "SUSE,openSUSE-Leap,42.2"
    "CentOS"        = "OpenLogic,CentOS,7.6"
    "Debian"        = "credativ,Debian,8"
    "CoreOS"        = "CoreOS,CoreOS,Stable"
    "SLES"          = "SUSE,SLES,12-SP2"
  }
}

output "value1" {
  value = contains([var.vm_os_simple, var.vm_os_offer], "WindowsServer")
}

output "value2" {
  value = var.vm_os_simple
}

output "value3" {
  value = var.vm_os_offer
}

output "value5" {
  value = ((false == contains([var.vm_os_simple, var.vm_os_offer], "WindowsServer")) && (var.is_windows_image != "true") && (var.data_disk == "false")) ? var.nb_instances : 0
}

