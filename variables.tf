variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "vms-rg"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "westus"
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
  description = "VM name referenced also in storage-related names."
  default = "mysweethost"
}

variable "vm_os_simple" {
  description = "Specify Ubuntu, Windows, RHEL, SUSE, CentOS, Debian, CoreOS, or SLES to get the latest image version of the specified os.  If this value is not provided, then vm_os_publisher, vm_os_offer, and vm_os_sku must be specified."
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

variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  default     = "azureuser"
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
  default = "CmplexP@ssw0rd"
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM"
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."
  default = {
    source = "terraform"
  }
}

variable "remote_port"{
  default = "22"
}

variable "dns_name" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default = "terrafrocks"
}