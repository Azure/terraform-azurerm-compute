# [DEPRECATED] terraform-azurerm-compute

> **NOTE:** This terraform-azurerm-compute module is now deprecated. The module will no longer receive updates or support. Users are encouraged to transition to the [avm-res-compute-virtualmachine](https://github.com/Azure/terraform-azurerm-avm-res-compute-virtualmachine) module for future deployments.

## Notice on new alternative virtual machine module

This module was designed and implemented for AzureRM Provider v2.x, It's impossible to refactor this module from `azurerm_virtual_machine` to the modern version `azurerm_linux_virtual_machine` and `azurerm_windows_virtual_machine`. For those who're maintaining infrastructure on brownfield, you're welcome to continue using this module; for those who're about to provision new infrastructure on greenfield, you're welcome to try our new alternative: [terraform-azurerm-virtual-machine](https://registry.terraform.io/modules/Azure/virtual-machine/azurerm/latest).

## Notice on Upgrade to v5.x

As [#218](https://github.com/Azure/terraform-azurerm-compute/pull/218) described, the `plan` block introduced by [#209](https://github.com/Azure/terraform-azurerm-compute/pull/209) was incorrect so we must adjust the assignments' order, which is a breaking change. The change we've made to vm's `plan` block is:

```hcl
dynamic "plan" {
  for_each = var.is_marketplace_image ? ["plan"] : []

  content {
  -      name      = var.vm_os_offer
  -      product   = var.vm_os_sku
  +      name      = var.vm_os_sku
  +      product   = var.vm_os_offer
    publisher = var.vm_os_publisher
  }
}
```

Now `vm_os_sku` would be used as `plan.name` and `vm_os_offer` would be used as `plan.product`.

v5.0.0 is a major version upgrade. Extreme caution must be taken during the upgrade to avoid resource replacement and downtime by accident.

## Notice on Upgrade to v4.x

We've added a CI pipeline for this module to speed up our code review and to enforce a high code quality standard, if you want to contribute by submitting a pull request, please read [Pre-Commit & Pr-Check & Test](#Pre-Commit--Pr-Check--Test) section, or your pull request might be rejected by CI pipeline.

A pull request will be reviewed when it has passed Pre Pull Request Check in the pipeline, and will be merged when it has passed the acceptance tests. Once the ci Pipeline failed, please read the pipeline's output, thanks for your cooperation.

v4.0.0 is a major version upgrade. Extreme caution must be taken during the upgrade to avoid resource replacement and downtime by accident.

Running the `terraform plan` first to inspect the plan is strongly advised.

## Deploys 1+ Virtual Machines to your provided VNet

This Terraform module deploys Virtual Machines in Azure with the following characteristics:

- Ability to specify a simple string to get the [latest marketplace image](https://docs.microsoft.com/cli/azure/vm/image?view=azure-cli-latest) using `var.vm_os_simple`
- All VMs use [managed disks](https://azure.microsoft.com/services/managed-disks/)
- Network Security Group (NSG) created with a single remote access rule which opens `var.remote_port` port or auto calculated port number if using `var.vm_os_simple` to all nics
- VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.vnet_subnet_id`.
- Control the number of Public IP addresses assigned to VMs via `var.nb_public_ip`. Create and attach one Public IP per VM up to the number of VMs or create NO public IPs via setting `var.nb_public_ip` to `0`.
- Control SKU and Allocation Method of the public IPs via `var.allocation_method` and `var.public_ip_sku`.

> Note: Terraform module registry is incorrect in the number of required parameters since it only deems required based on variables with non-existent values.  The actual minimum required variables depends on the configuration and is specified below in the usage.

## Usage in Terraform 0.13
```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]

  depends_on = [azurerm_resource_group.example]
}

module "windowsservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  is_windows_image    = true
  vm_hostname         = "mywinvm" // line can be removed if only one VM module per resource group
  admin_password      = "ComplxP@ssw0rd!"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["winsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]

  depends_on = [azurerm_resource_group.example]
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]

  depends_on = [azurerm_resource_group.example]
}

output "linux_vm_public_name" {
  value = module.linuxservers.public_ip_dns_name
}

output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}
```
## Simple Usage in Terraform 0.12

This contains the bare minimum options to be configured for the VM to be provisioned.  The entire code block provisions a Windows and a Linux VM, but feel free to delete one or the other and corresponding outputs. The outputs are also not necessary to provision, but included to make it convenient to know the address to connect to the VMs after provisioning completes.

Provisions an Ubuntu Server 16.04-LTS VM and a Windows 2016 Datacenter Server VM using `vm_os_simple` to a new VNet and opens up ports 22 for SSH and 3389 for RDP access via the attached public IP to each VM.  All resources are provisioned into the default resource group called `terraform-compute`.  The Ubuntu Server will use the ssh key found in the default location `~/.ssh/id_rsa.pub`.

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
}

module "windowsservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  is_windows_image    = true
  vm_hostname         = "mywinvm" // line can be removed if only one VM module per resource group
  admin_password      = "ComplxP@ssw0rd!"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["winsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]
}

output "linux_vm_public_name" {
  value = module.linuxservers.public_ip_dns_name
}

output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}
```

## Advanced Usage

The following example illustrates some of the configuration options available to deploy a virtual machine. Feel free to remove the Linux or Windows modules and corresponding outputs.

More specifically this provisions:

1 - New vnet for all vms

2 - Ubuntu 18.04 Server VMs using `vm_os_publisher`, `vm_os_offer` and `vm_os_sku` which is configured with:

- No public IP assigned, so access can only happen through another machine on the vnet.
- Opens up port 22 for SSH access with the default ~/.ssh/id_rsa.pub key
- Boot diagnostics is enabled.
- Additional tags are added to the resource group.
- OS disk is deleted upon deletion of the VM
- Add one 64GB premium managed data disk

2 - Windows Server 2012 R2 VMs using `vm_os_publisher`, `vm_os_offer` and `vm_os_sku` which is configured with:

- Two Public IP addresses (one for each VM)
- Public IP Addresses allocation method is Static and SKU is Standard
- Opens up port 3389 for RDP access using the password as shown

3 - New features are supported in v3.0.0:

- "nb_data_disk" Number of the data disks attached to each virtual machine

- "enable_ssh_key" Enable ssh key authentication in Linux virtual Machine.
  When ssh keys are enabled you can either
  - use the default "~/.ssh/id_rsa.pub"
  - set one key by setting a path in ssh_key variable. e.g "joey_id_rsa.pub"
  - set ssh_key and add zero or more files paths in extra_ssh_keys variable e.g. ["ross_id_rsa.pub", "rachel_id_rsa.pub"] (since v3.8.0)
  - set ssh_key_values as a list of raw public ssh keys values or refer it to a data source with the public key value, e.g. `["ssh-rsa AAAAB3NzaC1yc..."]`

4 - You can install custom certificates / secrets on the virtual machine from Key Vault by using the variable `os_profile_secrets`.

The variable accepts a list of maps with the following keys:

* source_vault_id : The ID of the Key Vault Secret which contains the encrypted Certificate.
* certificate_url : The certificate  URL in Key Vault
* certificate_store : The certificate store on the Virtual Machine where the certificate should be added to (Windows Only).

In the below example we use the data sources `azurerm_key_vault` and `azurerm_key_vault_certificate` to fetch the certificate information from Key Vault and add it to `windowsservers` via `os_profile_secrets` parameter.

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

data "azurerm_key_vault" "example" {
  name                = "examplekeyvault"
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_key_vault_certificate" "example" {
  name         = "example-kv-cert"
  key_vault_id = data.azurerm_key_vault.example.id
}

module "linuxservers" {
  source                           = "Azure/compute/azurerm"
  resource_group_name              = azurerm_resource_group.example.name
  vm_hostname                      = "mylinuxvm"
  nb_public_ip                     = 0
  remote_port                      = "22"
  nb_instances                     = 2
  vm_os_publisher                  = "Canonical"
  vm_os_offer                      = "UbuntuServer"
  vm_os_sku                        = "18.04-LTS"
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  boot_diagnostics                 = true
  delete_os_disk_on_termination    = true
  nb_data_disk                     = 2
  data_disk_size_gb                = 64
  data_sa_type                     = "Premium_LRS"
  enable_ssh_key                   = true
  ssh_key_values                   = ["ssh-rsa AAAAB3NzaC1yc2EAAAAD..."]
  vm_size                          = "Standard_D4s_v3"
  delete_data_disks_on_termination = true

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  enable_accelerated_networking = true
}

module "windowsservers" {
  source                        = "Azure/compute/azurerm"
  resource_group_name           = azurerm_resource_group.example.name
  vm_hostname                   = "mywinvm"
  is_windows_image              = true
  admin_password                = "ComplxP@ssw0rd!"
  allocation_method             = "Static"
  public_ip_sku                 = "Standard"
  public_ip_dns                 = ["winterravmip", "winterravmip1"]
  nb_public_ip                  = 2
  remote_port                   = "3389"
  nb_instances                  = 2
  vm_os_publisher               = "MicrosoftWindowsServer"
  vm_os_offer                   = "WindowsServer"
  vm_os_sku                     = "2012-R2-Datacenter"
  vm_size                       = "Standard_DS2_V2"
  vnet_subnet_id                = module.network.vnet_subnets[0]
  enable_accelerated_networking = true
  license_type                  = "Windows_Client"
  identity_type                 = "SystemAssigned" // can be empty, SystemAssigned or UserAssigned

  extra_disks = [
    {
      size = 50
      name = "logs"
    },
    {
      size = 200
      name = "backup"
    }
  ]

  os_profile_secrets = [{
    source_vault_id   = data.azurerm_key_vault.example.id
    certificate_url   = data.azurerm_key_vault_certificate.example.secret_id
    certificate_store = "My"
  }]
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]
}

output "linux_vm_private_ips" {
  value = module.linuxservers.network_interface_private_ip
}

output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}

output "windows_vm_public_ip" {
  value = module.windowsservers.public_ip_address
}

output "windows_vm_private_ips" {
  value = module.windowsservers.network_interface_private_ip
}

```

## Enable or disable tracing tags

We're using [BridgeCrew Yor](https://github.com/bridgecrewio/yor) and [yorbox](https://github.com/lonegunmanb/yorbox) to help manage tags consistently across infrastructure as code (IaC) frameworks. In this module you might see tags like:

```hcl
resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = random_pet.name
  tags = merge(var.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "3077cc6d0b70e29b6e106b3ab98cee6740c916f6"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-05-05 08:57:54"
    avm_git_org              = "lonegunmanb"
    avm_git_repo             = "terraform-yor-tag-test-module"
    avm_yor_trace            = "a0425718-c57d-401c-a7d5-f3d88b2551a4"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))
}
```

To enable tracing tags, set the variable to true:

```hcl
module "example" {
  source               = "{module_source}"
  ...
  tracing_tags_enabled = true
}
```

The `tracing_tags_enabled` is default to `false`.

To customize the prefix for your tracing tags, set the `tracing_tags_prefix` variable value in your Terraform configuration:

```hcl
module "example" {
  source              = "{module_source}"
  ...
  tracing_tags_prefix = "custom_prefix_"
}
```

The actual applied tags would be:

```text
{
  custom_prefix_git_commit           = "3077cc6d0b70e29b6e106b3ab98cee6740c916f6"
  custom_prefix_git_file             = "main.tf"
  custom_prefix_git_last_modified_at = "2023-05-05 08:57:54"
  custom_prefix_git_org              = "lonegunmanb"
  custom_prefix_git_repo             = "terraform-yor-tag-test-module"
  custom_prefix_yor_trace            = "a0425718-c57d-401c-a7d5-f3d88b2551a4"
}
```

## Pre-Commit & Pr-Check & Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

We assumed that you have setup service principal's credentials in your environment variables like below:

```shell
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```

On Windows Powershell:

```shell
$env:ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
$env:ARM_TENANT_ID="<azure_subscription_tenant_id>"
$env:ARM_CLIENT_ID="<service_principal_appid>"
$env:ARM_CLIENT_SECRET="<service_principal_password>"
```

We provide a docker image to run the pre-commit checks and tests for you: `mcr.microsoft.com/azterraform:latest`

To run the pre-commit task, we can run the following command:

```shell
$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit
```

On Windows Powershell:

```shell
$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit
```

NOTE: If an error occurs in Powershell that indicates `Argument or block definition required` for `unit-fixture/locals.tf` and/or `unit-fixture/variables.tf`, the issue could be that the symlink is not configured properly.  This can be fixed as described in [this link](https://stackoverflow.com/questions/5917249/git-symbolic-links-in-windows/59761201#59761201):

```shell
$ git config core.symlinks true
```

Then switch branches, or execute git reset:

```shell
$ git reset --hard HEAD
```

In pre-commit task, we will:

1. Run `terraform fmt -recursive` command for your Terraform code.
2. Run `terrafmt fmt -f` command for markdown files and go code files to ensure that the Terraform code embedded in these files are well formatted.
3. Run `go mod tidy` and `go mod vendor` for test folder to ensure that all the dependencies have been synced.
4. Run `gofmt` for all go code files.
5. Run `gofumpt` for all go code files.
6. Run `terraform-docs` on `README.md` file, then run `markdown-table-formatter` to format markdown tables in `README.md`.

Then we can run the pr-check task to check whether our code meets our pipeline's requirement(We strongly recommend you run the following command before you commit):

```shell
$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pr-check
```

On Windows Powershell:

```shell
$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pr-check
```

To run the e2e-test, we can run the following command:

```text
docker run --rm -v $(pwd):/src -w /src -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET mcr.microsoft.com/azterraform:latest make e2e-test
```

On Windows Powershell:

```text
docker run --rm -v ${pwd}:/src -w /src -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET mcr.microsoft.com/azterraform:latest make e2e-test
```

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

## Authors

Originally created by [David Tesar](http://github.com/dtzar)

## License

[MIT](LICENSE)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.11, < 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.11, < 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_os"></a> [os](#module\_os) | ./os | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_managed_disk.vm_data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_managed_disk.vm_extra_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_storage_account.vm_sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_virtual_machine.vm_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine.vm_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine_data_disk_attachment.vm_data_disk_attachments_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.vm_data_disk_attachments_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.vm_extra_disk_attachments_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.vm_extra_disk_attachments_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.extensions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [random_id.vm_sa](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_public_ip.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure. | `string` | `""` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username of the VM that will be deployed. | `string` | `"azureuser"` | no |
| <a name="input_allocation_method"></a> [allocation\_method](#input\_allocation\_method) | Defines how an IP address is assigned. Options are Static or Dynamic. | `string` | `"Dynamic"` | no |
| <a name="input_as_platform_fault_domain_count"></a> [as\_platform\_fault\_domain\_count](#input\_as\_platform\_fault\_domain\_count) | (Optional) Specifies the number of fault domains that are used. Defaults to `2`. Changing this forces a new resource to be created. | `number` | `2` | no |
| <a name="input_as_platform_update_domain_count"></a> [as\_platform\_update\_domain\_count](#input\_as\_platform\_update\_domain\_count) | (Optional) Specifies the number of update domains that are used. Defaults to `2`. Changing this forces a new resource to be created. | `number` | `2` | no |
| <a name="input_availability_set_enabled"></a> [availability\_set\_enabled](#input\_availability\_set\_enabled) | (Optional) Enable or Disable availability set.  Default is `true` (enabled). | `bool` | `true` | no |
| <a name="input_boot_diagnostics"></a> [boot\_diagnostics](#input\_boot\_diagnostics) | (Optional) Enable or Disable boot diagnostics. | `bool` | `false` | no |
| <a name="input_boot_diagnostics_sa_type"></a> [boot\_diagnostics\_sa\_type](#input\_boot\_diagnostics\_sa\_type) | (Optional) Storage account type for boot diagnostics. | `string` | `"Standard_LRS"` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | The custom data to supply to the machine. This can be used as a cloud-init for Linux systems. | `string` | `""` | no |
| <a name="input_data_disk_size_gb"></a> [data\_disk\_size\_gb](#input\_data\_disk\_size\_gb) | Storage data disk size size. | `number` | `30` | no |
| <a name="input_data_sa_type"></a> [data\_sa\_type](#input\_data\_sa\_type) | Data Disk Storage Account type. | `string` | `"Standard_LRS"` | no |
| <a name="input_delete_data_disks_on_termination"></a> [delete\_data\_disks\_on\_termination](#input\_delete\_data\_disks\_on\_termination) | Delete data disks when machine is terminated. | `bool` | `false` | no |
| <a name="input_delete_os_disk_on_termination"></a> [delete\_os\_disk\_on\_termination](#input\_delete\_os\_disk\_on\_termination) | Delete OS disk when machine is terminated. | `bool` | `false` | no |
| <a name="input_enable_accelerated_networking"></a> [enable\_accelerated\_networking](#input\_enable\_accelerated\_networking) | (Optional) Enable accelerated networking on Network interface. | `bool` | `false` | no |
| <a name="input_enable_ip_forwarding"></a> [enable\_ip\_forwarding](#input\_enable\_ip\_forwarding) | (Optional) Should IP Forwarding be enabled? Defaults to `false`. | `bool` | `false` | no |
| <a name="input_enable_ssh_key"></a> [enable\_ssh\_key](#input\_enable\_ssh\_key) | (Optional) Enable ssh key authentication in Linux virtual Machine. | `bool` | `true` | no |
| <a name="input_external_boot_diagnostics_storage"></a> [external\_boot\_diagnostics\_storage](#input\_external\_boot\_diagnostics\_storage) | (Optional) The Storage Account's Blob Endpoint which should hold the virtual machine's diagnostic files. Set this argument would disable the creation of `azurerm_storage_account` resource. | <pre>object({<br>    uri = string<br>  })</pre> | `null` | no |
| <a name="input_extra_disks"></a> [extra\_disks](#input\_extra\_disks) | (Optional) List of extra data disks attached to each virtual machine. | <pre>list(object({<br>    name = string<br>    size = number<br>  }))</pre> | `[]` | no |
| <a name="input_extra_ssh_keys"></a> [extra\_ssh\_keys](#input\_extra\_ssh\_keys) | Same as ssh\_key, but allows for setting multiple public keys. Set your first key in ssh\_key, and the extras here. | `list(string)` | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_is_marketplace_image"></a> [is\_marketplace\_image](#input\_is\_marketplace\_image) | Boolean flag to notify when the image comes from the marketplace. | `bool` | `false` | no |
| <a name="input_is_windows_image"></a> [is\_windows\_image](#input\_is\_windows\_image) | Boolean flag to notify when the custom image is windows based. | `bool` | `false` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows\_Client and Windows\_Server | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) The location in which the resources will be created. | `string` | `null` | no |
| <a name="input_managed_data_disk_encryption_set_id"></a> [managed\_data\_disk\_encryption\_set\_id](#input\_managed\_data\_disk\_encryption\_set\_id) | (Optional) The disk encryption set ID for the managed data disk attached using the azurerm\_virtual\_machine\_data\_disk\_attachment resource. | `string` | `null` | no |
| <a name="input_name_template_availability_set"></a> [name\_template\_availability\_set](#input\_name\_template\_availability\_set) | The name template for the availability set. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`. All other text can be set as desired. | `string` | `"${vm_hostname}-avset"` | no |
| <a name="input_name_template_data_disk"></a> [name\_template\_data\_disk](#input\_name\_template\_data\_disk) | The name template for the data disks. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index', `${data_disk_number}` => 'data disk index'. All other text can be set as desired. | `string` | `"${vm_hostname}-datadisk-${host_number}-${data_disk_number}"` | no |
| <a name="input_name_template_extra_disk"></a> [name\_template\_extra\_disk](#input\_name\_template\_extra\_disk) | The name template for the extra disks. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index', `${extra_disk_name}` => 'name of extra disk'. All other text can be set as desired. | `string` | `"${vm_hostname}-extradisk-${host_number}-${extra_disk_name}"` | no |
| <a name="input_name_template_network_interface"></a> [name\_template\_network\_interface](#input\_name\_template\_network\_interface) | The name template for the network interface. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-nic-${host_number}"` | no |
| <a name="input_name_template_network_security_group"></a> [name\_template\_network\_security\_group](#input\_name\_template\_network\_security\_group) | The name template for the network security group. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`. All other text can be set as desired. | `string` | `"${vm_hostname}-nsg"` | no |
| <a name="input_name_template_public_ip"></a> [name\_template\_public\_ip](#input\_name\_template\_public\_ip) | The name template for the public ip. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${ip_number}` => 'public ip index'. All other text can be set as desired. | `string` | `"${vm_hostname}-pip-${ip_number}"` | no |
| <a name="input_name_template_vm_linux"></a> [name\_template\_vm\_linux](#input\_name\_template\_vm\_linux) | The name template for the Linux virtual machine. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-vmLinux-${host_number}"` | no |
| <a name="input_name_template_vm_linux_os_disk"></a> [name\_template\_vm\_linux\_os\_disk](#input\_name\_template\_vm\_linux\_os\_disk) | The name template for the Linux VM OS disk. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"osdisk-${vm_hostname}-${host_number}"` | no |
| <a name="input_name_template_vm_windows"></a> [name\_template\_vm\_windows](#input\_name\_template\_vm\_windows) | The name template for the Windows virtual machine. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-vmWindows-${host_number}"` | no |
| <a name="input_name_template_vm_windows_os_disk"></a> [name\_template\_vm\_windows\_os\_disk](#input\_name\_template\_vm\_windows\_os\_disk) | The name template for the Windows VM OS disk. The following replacements are automatically made: `${vm_hostname}` => `var.vm_hostname`, `${host_number}` => 'host index'. All other text can be set as desired. | `string` | `"${vm_hostname}-osdisk-${host_number}"` | no |
| <a name="input_nb_data_disk"></a> [nb\_data\_disk](#input\_nb\_data\_disk) | (Optional) Number of the data disks attached to each virtual machine. | `number` | `0` | no |
| <a name="input_nb_instances"></a> [nb\_instances](#input\_nb\_instances) | Specify the number of vm instances. | `number` | `1` | no |
| <a name="input_nb_public_ip"></a> [nb\_public\_ip](#input\_nb\_public\_ip) | Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses. | `number` | `1` | no |
| <a name="input_nested_data_disks"></a> [nested\_data\_disks](#input\_nested\_data\_disks) | (Optional) When `true`, use nested data disks directly attached to the VM.  When `false`, use azurerm\_virtual\_machine\_data\_disk\_attachment resource to attach the data disks after the VM is created.  Default is `true`. | `bool` | `true` | no |
| <a name="input_network_security_group"></a> [network\_security\_group](#input\_network\_security\_group) | The network security group we'd like to bind with virtual machine. Set this variable will disable the creation of `azurerm_network_security_group` and `azurerm_network_security_rule` resources. | <pre>object({<br>    id = string<br>  })</pre> | `null` | no |
| <a name="input_os_profile_secrets"></a> [os\_profile\_secrets](#input\_os\_profile\_secrets) | Specifies a list of certificates to be installed on the VM, each list item is a map with the keys source\_vault\_id, certificate\_url and certificate\_store. | `list(map(string))` | `[]` | no |
| <a name="input_public_ip_dns"></a> [public\_ip\_dns](#input\_public\_ip\_dns) | Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb\_public\_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_public_ip_sku"></a> [public\_ip\_sku](#input\_public\_ip\_sku) | Defines the SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. | `string` | `"Basic"` | no |
| <a name="input_remote_port"></a> [remote\_port](#input\_remote\_port) | Remote tcp port to be used for access to the vms created via the nsg applied to the nics. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resources will be created. | `string` | n/a | yes |
| <a name="input_source_address_prefixes"></a> [source\_address\_prefixes](#input\_source\_address\_prefixes) | (Optional) List of source address prefixes allowed to access var.remote\_port. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash.e.g. c : /home/id\_rsa.pub. | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_ssh_key_values"></a> [ssh\_key\_values](#input\_ssh\_key\_values) | List of Public SSH Keys values to be used for ssh access to the VMs. | `list(string)` | `[]` | no |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | Defines the type of storage account to be created. Valid options are Standard\_LRS, Standard\_ZRS, Standard\_GRS, Standard\_RAGRS, Premium\_LRS. | `string` | `"Premium_LRS"` | no |
| <a name="input_storage_os_disk_size_gb"></a> [storage\_os\_disk\_size\_gb](#input\_storage\_os\_disk\_size\_gb) | (Optional) Specifies the size of the data disk in gigabytes. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |
| <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled) | Whether enable tracing tags that generated by BridgeCrew Yor. | `bool` | `false` | no |
| <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix) | Default prefix for generated tracing tags | `string` | `"avm_"` | no |
| <a name="input_vm_extension"></a> [vm\_extension](#input\_vm\_extension) | (Deprecated) This variable has been superseded by the `vm_extensions`. Argument to create `azurerm_virtual_machine_extension` resource, the argument descriptions could be found at [the document](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension). | <pre>object({<br>    name                        = string<br>    publisher                   = string<br>    type                        = string<br>    type_handler_version        = string<br>    auto_upgrade_minor_version  = optional(bool)<br>    automatic_upgrade_enabled   = optional(bool)<br>    failure_suppression_enabled = optional(bool, false)<br>    settings                    = optional(string)<br>    protected_settings          = optional(string)<br>    protected_settings_from_key_vault = optional(object({<br>      secret_url      = string<br>      source_vault_id = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_vm_extensions"></a> [vm\_extensions](#input\_vm\_extensions) | Argument to create `azurerm_virtual_machine_extension` resource, the argument descriptions could be found at [the document](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension). | <pre>set(object({<br>    name                        = string<br>    publisher                   = string<br>    type                        = string<br>    type_handler_version        = string<br>    auto_upgrade_minor_version  = optional(bool)<br>    automatic_upgrade_enabled   = optional(bool)<br>    failure_suppression_enabled = optional(bool, false)<br>    settings                    = optional(string)<br>    protected_settings          = optional(string)<br>    protected_settings_from_key_vault = optional(object({<br>      secret_url      = string<br>      source_vault_id = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_vm_hostname"></a> [vm\_hostname](#input\_vm\_hostname) | local name of the Virtual Machine. | `string` | `"myvm"` | no |
| <a name="input_vm_os_id"></a> [vm\_os\_id](#input\_vm\_os\_id) | The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is\_windows\_image = true for windows custom images. | `string` | `""` | no |
| <a name="input_vm_os_offer"></a> [vm\_os\_offer](#input\_vm\_os\_offer) | The name of the offer of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_publisher"></a> [vm\_os\_publisher](#input\_vm\_os\_publisher) | The name of the publisher of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_simple"></a> [vm\_os\_simple](#input\_vm\_os\_simple) | Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm\_os\_publisher, vm\_os\_offer, and vm\_os\_sku. | `string` | `""` | no |
| <a name="input_vm_os_sku"></a> [vm\_os\_sku](#input\_vm\_os\_sku) | The sku of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `""` | no |
| <a name="input_vm_os_version"></a> [vm\_os\_version](#input\_vm\_os\_version) | The version of the image that you want to deploy. This is ignored when vm\_os\_id or vm\_os\_simple are provided. | `string` | `"latest"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Specifies the size of the virtual machine. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | The subnet id of the virtual network where the virtual machines will reside. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | (Optional) The Availability Zone which the Virtual Machine should be allocated in, only one zone would be accepted. If set then this module won't create `azurerm_availability_set` resource. Changing this forces a new resource to be created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_set_id"></a> [availability\_set\_id](#output\_availability\_set\_id) | Id of the availability set where the vms are provisioned. If `var.zones` is set, this output will return empty string. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | ids of the vm nics provisoned. |
| <a name="output_network_interface_private_ip"></a> [network\_interface\_private\_ip](#output\_network\_interface\_private\_ip) | private ip addresses of the vm nics |
| <a name="output_network_security_group_id"></a> [network\_security\_group\_id](#output\_network\_security\_group\_id) | id of the security group provisioned |
| <a name="output_network_security_group_name"></a> [network\_security\_group\_name](#output\_network\_security\_group\_name) | name of the security group provisioned, empty if no security group was created. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The actual ip address allocated for the resource. |
| <a name="output_public_ip_dns_name"></a> [public\_ip\_dns\_name](#output\_public\_ip\_dns\_name) | fqdn to connect to the first vm provisioned. |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | id of the public ip address provisoned. |
| <a name="output_vm_identity"></a> [vm\_identity](#output\_vm\_identity) | map with key `Virtual Machine Id`, value `list of identity` created for the Virtual Machine. |
| <a name="output_vm_ids"></a> [vm\_ids](#output\_vm\_ids) | Virtual machine ids created. |
| <a name="output_vm_names"></a> [vm\_names](#output\_vm\_names) | Virtual machine names created. |
| <a name="output_vm_zones"></a> [vm\_zones](#output\_vm\_zones) | map with key `Virtual Machine Id`, value `list of the Availability Zone` which the Virtual Machine should be allocated in. |
<!-- END_TF_DOCS -->
