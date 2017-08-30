
variable "vm_os_simple" {
}

# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
variable "standard_os" {
  default  = {
    "Ubuntu"  = "Canonical,UbuntuServer,16.04-LTS"
    "Windows" = "MicrosoftWindows,WindowsServer,2016-Datacenter"
    "RHEL"    = "RedHat,RHEL,7.3"
    "SUSE"    = "SUSE,openSUSE-Leap,42.2"
    "CentOS"  = "OpenLogic,CentOS,7.3"
    "Debian"  = "credativ,Debian,8"
    "CoreOS"  = "CoreOS,CoreOS,Stable"
    "SLES"    = "SUSE,SLES,12-SP2"
    }
}
