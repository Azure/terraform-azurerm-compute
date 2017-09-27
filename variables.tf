variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "compute"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "vnet_subnet_id"{
  description = "The subnet id of the virtual network where the virtual machines will reside."
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to the public ip address. e.g. thisvar.varlocation.cloudapp.azure.com"
  default = ""
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
  default = ""
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub"
  default     = "~/.ssh/id_rsa.pub"
}

variable "remote_port"{
  description = "Remote tcp port to be used for access to the vms created via the nsg applied to the nics."
  default = ""
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  default     = "azureuser"
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  default     = "Premium_LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_V2"
}

variable "nb_instances" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "vm_hostname" {
  description = "local name of the VM"
  default = "myvm"
}

variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  default = ""
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy.  Not necessary if using vm_os_simple."
  default = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. Not necessary if using vm_os_simple."
  default = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. Not necessary if using vm_os_simple."
  default = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy."
  default = "latest"
}

variable "vm_os_id" {
  description = "The ID of the image that you want to deploy if you are using a custom image."
  default = ""
}

variable "tags" {
  type = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."
  default = {
    source = "terraform"
  }
}
variable "public_ip_address_allocation" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default = "static"
}

variable "boot_diagnostics" {
  description = "(Optional) Enable or Disable boot diagnostics"
  default = "false"
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics"
  default = "Standard_LRS"
}
  
variable "public_ip" {
  description = "(Optional) Add Public IP or not"
  default = "true"
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type"
  default = "Standard_LRS"
}

variable "data_disk_size_gb" {
  description = "Data disk size in Gb"
  default = 1
}