# terraform-azurerm-compute

[![Build Status](https://travis-ci.org/Azure/terraform-azurerm-compute.svg?branch=master)](https://travis-ci.org/Azure/terraform-azurerm-compute)

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

## Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
- [Generate and add SSH Key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) Save the key in ~/.ssh/id_rsa.  This is not required for Windows deployments.

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native (Mac/Linux)

#### Prerequisites

- [Ruby **(~> 2.3)**](https://www.ruby-lang.org/en/downloads/)
- [Bundler **(~> 1.15)**](https://bundler.io/)
- [Terraform **(~> 0.11.7)**](https://www.terraform.io/downloads.html)
- [Golang **(~> 1.10.3)**](https://golang.org/dl/)

#### Quick Run

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

Then simply run it in local shell:

```sh
$ cd $GOPATH/src/{directory_name}/
$ bundle install
$ rake build
$ rake e2e
```

### Docker

We provide a Dockerfile to build a new image based `FROM` the `microsoft/terraform-test` Docker hub image which adds additional tools / packages specific for this module (see Custom Image section).  Alternatively use only the `microsoft/terraform-test` Docker hub image [by using these instructions](https://github.com/Azure/terraform-test).

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

#### Custom Image

This builds the custom image:

```sh
$ docker build --build-arg BUILD_ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID --build-arg BUILD_ARM_CLIENT_ID=$ARM_CLIENT_ID --build-arg BUILD_ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET --build-arg BUILD_ARM_TENANT_ID=$ARM_TENANT_ID -t azure-compute .
```

This runs the build and unit tests:

```sh
$ docker run --rm azure-compute /bin/bash -c "bundle install && rake build"
```

This runs the end to end tests:

```sh
$ docker run --rm azure-compute /bin/bash -c "bundle install && rake e2e"
```

This runs the full tests:

```sh
$ docker run --rm azure-compute /bin/bash -c "bundle install && rake full"
```

## Authors

Originally created by [David Tesar](http://github.com/dtzar)

## License

[MIT](LICENSE)
