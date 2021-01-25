variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "location" {
  description = "(Optional) The location in which the resources will be created."
  type        = string
  default     = "Canada Central"
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  type        = list(string)
  default     = [null]
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = ""
}

variable "extra_ssh_keys" {
  description = "Same as ssh_key, but allows for setting multiple public keys. Set your first key in ssh_key, and the extras here."
  type        = list(string)
  default     = []
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_key_values" {
  description = "List of Public SSH Keys values to be used for ssh access to the VMs."
  type        = list(string)
  default     = []
}
variable "remote_port" {
  description = "Remote tcp port to be used for access to the vms created via the nsg applied to the nics."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = "azureadmin"
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = ""
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Premium_LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_B2s"
}

variable "nb_instances" {
  description = "Specify the number of vm instances."
  type        = number
  default     = 1
}

variable "vm_hostname" {
  description = "Name of the Virtual Machine."
  type        = string
  validation {
    condition     = length(var.vm_hostname) <= 13
    error_message = "The VM name can be at most 13 characters. Adjust the \"vm_name\" variable."
  }
}

variable "vm_os_simple" {
  description = "Specify WindowsServer to get the latest image version of the specified os."
  type        = string
  default     = "WindowsServer"
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "A map of the tags to use on the resources that are deployed with this module"
  type        = map(string)

  validation {
    condition     = can(var.tags["Environment"])
    error_message = "The Environment tag is required! Please add one."
  }
  validation {
    condition     = can(var.tags["CostCenter"])
    error_message = "The CostCenter tag is required! Please add one."
  }
  validation {
    condition     = can(var.tags["App"])
    error_message = "The App tag is required! Please add one."
  }
  validation {
    condition     = can(var.tags["Importance"])
    error_message = "The Importance tag is required! Please add one. Value can be, high, medium or low."
  }
}
# Create a local variable so that the interpolation can work. Merge the info with the tags variable.
locals {
  tags = merge(
    var.tags,
    {
      Source = "terraform"
    },
  )
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable "public_ip_sku" {
  description = "Defines the SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic."
  type        = string
  default     = "Basic"
}

variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  type        = number
  default     = 0
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when machine is terminated."
  default     = false
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type."
  type        = string
  default     = "Standard_LRS"
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = number
  default     = 30
}

variable "boot_diagnostics" {
  type        = bool
  description = "(Optional) Enable or Disable boot diagnostics."
  default     = false
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics."
  type        = string
  default     = "Standard_LRS"
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface."
  default     = false
}

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
  default     = true
}

variable "data_disk" {
  description = "(Optional) Add a data disk to the VM if true."
  type        = bool
  default     = false
}

variable "source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}


variable "os_profile_secrets" {
  description = "Specifies a list of certificates to be installed on the VM, each list item is a map with the keys source_vault_id, certificate_url and certificate_store."
  type        = list(map(string))
  default     = []
}
variable "subnet_name" {
  description = "(Optional) The name of the subnet to use for this VM"
  type        = string
  default     = "snet-prod-spoke-workload-default"
}
variable "virtual_network_name" {
  description = "(Optional) Specifies the name of the Virtual Network the subnet is located within"
  type        = string
  default     = "vnet-prod-spoke-workload"
}
variable "vnet_resource_group" {
  description = "(Optional) Specifies the name of the resource group the Virtual Network is located in"
  type        = string
  default     = "rg-prod-01-canadacentral-mca"
}
variable "automatic_updates" {
  description = "(Optional) Enable or not the automatic OS updates"
  type        = bool
  default     = true
}
variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image."
  type        = string
  default     = ""
}
