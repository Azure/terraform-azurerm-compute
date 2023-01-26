variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = string
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = "azureuser"
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

# We keep default value as `2`, not `3` as the official since this module used to hard code this argument to `2`.
variable "as_platform_fault_domain_count" {
  description = "(Optional) Specifies the number of fault domains that are used. Defaults to `2`. Changing this forces a new resource to be created."
  type        = number
  default     = 2
}

# We keep default value as `2`, not `5` as the official since this module used to hard code this argument to `2`.
variable "as_platform_update_domain_count" {
  description = "(Optional) Specifies the number of update domains that are used. Defaults to `2`. Changing this forces a new resource to be created."
  type        = number
  default     = 2
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

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = ""
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = number
  default     = 30
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type."
  type        = string
  default     = "Standard_LRS"
}

variable "delete_data_disks_on_termination" {
  type        = bool
  description = "Delete data disks when machine is terminated."
  default     = false
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete OS disk when machine is terminated."
  default     = false
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

# Why use object as type? We use this variable in `count` expression, if we use a newly created `azurerm_storage_account.primary_blob_endpoint` as uri directly, then Terraform would complain that it cannot determine the value of `count` during the plan phase, so we wrap the `uri` with an object.
variable "external_boot_diagnostics_storage" {
  description = "(Optional) The Storage Account's Blob Endpoint which should hold the virtual machine's diagnostic files. Set this argument would disable the creation of `azurerm_storage_account` resource."
  type = object({
    uri = string
  })
  default = null
  validation {
    condition     = var.external_boot_diagnostics_storage == null ? true : var.external_boot_diagnostics_storage.uri != null
    error_message = "`var.external_boot_diagnostics_storage.uri` cannot be `null`"
  }
}

variable "extra_disks" {
  description = "(Optional) List of extra data disks attached to each virtual machine."
  type = list(object({
    name = string
    size = number
  }))
  default = []
}

variable "extra_ssh_keys" {
  description = "Same as ssh_key, but allows for setting multiple public keys. Set your first key in ssh_key, and the extras here."
  type        = list(string)
  default     = []
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "is_marketplace_image" {
  description = "Boolean flag to notify when the image comes from the marketplace."
  type        = bool
  nullable    = false
  default     = false
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  type        = bool
  default     = false
}

variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  type        = string
  default     = null
}

variable "location" {
  description = "(Optional) The location in which the resources will be created."
  type        = string
  default     = null
}

variable "nb_data_disk" {
  description = "(Optional) Number of the data disks attached to each virtual machine."
  type        = number
  default     = 0
}

variable "nb_instances" {
  description = "Specify the number of vm instances."
  type        = number
  default     = 1
}

variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  type        = number
  default     = 1
}

variable "network_security_group" {
  description = "The network security group we'd like to bind with virtual machine. Set this variable will disable the creation of `azurerm_network_security_group` and `azurerm_network_security_rule` resources.  To prevent the binding of a network security group, set `enable_network_security_group` to false."
  type = object({
    id = string
  })
  default = null
  validation {
    condition     = var.network_security_group == null ? true : var.network_security_group.id != null
    error_message = "When `var.network_security_group` is not `null`, `var.network_security_group.id` is required."
  }
}

variable "os_profile_secrets" {
  description = "Specifies a list of certificates to be installed on the VM, each list item is a map with the keys source_vault_id, certificate_url and certificate_store."
  type        = list(map(string))
  default     = []
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  type        = list(string)
  default     = [null]
}

variable "public_ip_sku" {
  description = "Defines the SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic."
  type        = string
  default     = "Basic"
}

variable "remote_port" {
  description = "Remote tcp port to be used for access to the vms created via the nsg applied to the nics."
  type        = string
  default     = ""
}

variable "source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash.e.g. c : /home/id_rsa.pub."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_key_values" {
  description = "List of Public SSH Keys values to be used for ssh access to the VMs."
  type        = list(string)
  default     = []
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Premium_LRS"
}

variable "storage_os_disk_size_gb" {
  description = "(Optional) Specifies the size of the data disk in gigabytes."
  type        = number
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "vm_extension" {
  description = "(Deprecated) This variable has been superseded by the `vm_extensions`. Argument to create `azurerm_virtual_machine_extension` resource, the argument descriptions could be found at [the document](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension)."
  type = object({
    name                        = string
    publisher                   = string
    type                        = string
    type_handler_version        = string
    auto_upgrade_minor_version  = optional(bool)
    automatic_upgrade_enabled   = optional(bool)
    failure_suppression_enabled = optional(bool, false)
    settings                    = optional(string)
    protected_settings          = optional(string)
    protected_settings_from_key_vault = optional(object({
      secret_url      = string
      source_vault_id = string
    }))
  })
  default   = null
  sensitive = true # Because `protected_settings` is sensitive
}

variable "vm_extensions" {
  description = "Argument to create `azurerm_virtual_machine_extension` resource, the argument descriptions could be found at [the document](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension)."
  type = set(object({
    name                        = string
    publisher                   = string
    type                        = string
    type_handler_version        = string
    auto_upgrade_minor_version  = optional(bool)
    automatic_upgrade_enabled   = optional(bool)
    failure_suppression_enabled = optional(bool, false)
    settings                    = optional(string)
    protected_settings          = optional(string)
    protected_settings_from_key_vault = optional(object({
      secret_url      = string
      source_vault_id = string
    }))
  }))
  # tflint-ignore: terraform_sensitive_variable_no_default
  default   = []
  nullable  = false
  sensitive = true # Because `protected_settings` is sensitive
  validation {
    condition = length(var.vm_extensions) == length(distinct([
      for e in var.vm_extensions : e.type
    ]))
    error_message = "`type` in `vm_extensions` must be unique."
  }
  validation {
    condition = length(var.vm_extensions) == length(distinct([
      for e in var.vm_extensions : e.name
    ]))
    error_message = "`name` in `vm_extensions` must be unique."
  }
}

variable "vm_hostname" {
  description = "local name of the Virtual Machine."
  type        = string
  default     = "myvm"
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  type        = string
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  type        = string
  default     = ""
}

variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
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

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_D2s_v3"
}

# Why we use `zone` not `zones` as `azurerm_virtual_machine.zones`?
# `azurerm_virtual_machine.zones` is [a list of single Az](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#zones), the maximum length is `1`
# so we can only pass one zone per vm instance.
# Why don't we use [`element`](https://developer.hashicorp.com/terraform/language/functions/element) function?
# The `element` function act as mod operator, it will iterate the vm instances, meanwhile
# we must keep the vm and public ip in the same zone.
# The vm's count is controlled by `var.nb_instances` and public ips' count is controled by `var.nb_public_ip`,
# it would be hard for us to keep the vm and public ip in the same zone once `var.nb_instances` doesn't equal to `var.nb_public_ip`
# So, we decide that one module instance supports one zone only to avoid this dilemma.
variable "zone" {
  description = "(Optional) The Availability Zone which the Virtual Machine should be allocated in, only one zone would be accepted. If set then this module won't create `azurerm_availability_set` resource. Changing this forces a new resource to be created.  To prevent the usage of an availability set, set `enable_availability_set` to false."
  type        = string
  default     = null
}

variable "nb_data_disk_by_data_disk_attachment" {
  description = "(Optional) Number of the data disks attached to each virtual machine using a azurerm_virtual_machine_data_disk_attachment resource.  Data Disks can be attached either directly by `nb_data_disk` and `extra_disks`, or using the azurerm_virtual_machine_data_disk_attachment resource by `nb_data_disk_by_data_disk_attachment` and `extra_disks_by_data_disk_attachment` - but the two cannot be used together."
  type        = number
  default     = 0
}

variable "extra_disks_by_data_disk_attachment" {
  description = "(Optional) List of extra data disks attached to each virtual machine using a azurerm_virtual_machine_data_disk_attachment resource.  Data Disks can be attached either directly by `nb_data_disk` and `extra_disks`, or using the azurerm_virtual_machine_data_disk_attachment resource by `nb_data_disk_by_data_disk_attachment` and `extra_disks_by_data_disk_attachment` - but the two cannot be used together."
  type = list(object({
    name = string
    size = number
  }))
  default = []
}

variable "storage_account_name" {
  description = "(Optional) The name of a Storage Account to create.  Leave empty to skip creating the storage account.  IMPORTANT: Must be lower case letters and numbers ONLY!"
  type        = string
  default     = null
}

variable "enable_availability_set" {
  type        = bool
  description = "(Optional) Enable or Disable availability set.  Default is true (enabled)."
  default     = true
}

variable "enable_network_security_group" {
  type        = bool
  description = "(Optional) Enable or Disable network security group.  Default is true (enabled)."
  default     = true
}

variable "group_by_vm_instance" {
  type        = bool
  description = "(Optional) Enable or Disable grouping by vm instances.  Default is to group by type."
  default     = false
}

