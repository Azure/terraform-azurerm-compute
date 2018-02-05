# terraform-azurerm-compute #
[![Build Status](https://travis-ci.org/Azure/terraform-azurerm-compute.svg?branch=master)](https://travis-ci.org/Azure/terraform-azurerm-compute)

Deploys 1+ Virtual Machines to your provided VNet
=================================================

This Terraform module deploys Virtual Machines in Azure with the following characteristics:

- Ability to specify a simple string to get the [latest marketplace image](https://docs.microsoft.com/cli/azure/vm/image?view=azure-cli-latest) using `var.vm_os_simple`
- All VMs use [managed disks](https://azure.microsoft.com/services/managed-disks/)
- Network Security Group (NSG) created with a single remote access rule which opens `var.remote_port` port or auto calculated port number if using `var.vm_os_simple` to all nics
- VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.vnet_subnet_id`.
- Control the number of Public IP addresses assigned to VMs via `var.nb_public_ip`. Create and attach one Public IP per VM up to the number of VMs or create NO public IPs via setting `var.nb_public_ip` to `0`.

> Note: Terraform module registry is incorrect in the number of required parameters since it only deems required based on variables with non-existent values.  The actual minimum required variables depends on the configuration and is specified below in the usage.

Simple Usage
-----

This contains the bare minimum options to be configured for the VM to be provisioned.  The entire code block provisions a Windows and a Linux VM, but feel free to delete one or the other and corresponding outputs. The outputs are also not necessary to provision, but included to make it convenient to know the address to connect to the VMs after provisioning completes.

Provisions an Ubuntu Server 16.04-LTS VM and a Windows 2016 Datacenter Server VM using `vm_os_simple` to a new VNet and opens up ports 22 for SSH and 3389 for RDP access via the attached public IP to each VM.  All resources are provisioned into the default resource group called `terraform-compute`.  The Ubuntu Server will use the ssh key found in the default location `~/.ssh/id_rsa.pub`.

```hcl
  module "linuxservers" {
    source              = "Azure/compute/azurerm"
    location            = "West US 2"
    vm_os_simple        = "UbuntuServer"
    public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  }

  module "windowsservers" {
    source              = "Azure/compute/azurerm"
    location            = "West US 2"
    vm_hostname         = "mywinvm" // line can be removed if only one VM module per resource group
    admin_password      = "ComplxP@ssw0rd!"
    vm_os_simple        = "WindowsServer"
    public_ip_dns       = ["winsimplevmips"] // change to a unique name per datacenter region
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  }

  module "network" {
    source              = "Azure/network/azurerm"
    version             = "~> 1.1.1"
    location            = "West US 2"
    allow_rdp_traffic   = "true"
    allow_ssh_traffic   = "true"
    resource_group_name = "terraform-compute"
  }

  output "linux_vm_public_name"{
    value = "${module.linuxservers.public_ip_dns_name}"
  }

  output "windows_vm_public_name"{
    value = "${module.windowsservers.public_ip_dns_name}"
  }
```

Advanced Usage
-----

The following example illustrates some of the configuration options available to deploy a virtual machine. Feel free to remove the Linux or Windows modules and corresponding outputs.

More specifically this provisions:

1 - New vnet for all vms

2 - Ubuntu 14.04 Server VMs using `vm_os_publisher`, `vm_os_offer` and `vm_os_sku` which is configured with:

- No public IP assigned, so access can only happen through another machine on the vnet.
- Opens up port 22 for SSH access with the default ~/.ssh/id_rsa.pub key
- Boot diagnostics is enabled.
- Additional tags are added to the resource group.
- OS disk is deleted upon deletion of the VM
- Add one 64GB premium managed data disk

2 - Windows Server 2012 R2 VMs using `vm_os_publisher`, `vm_os_offer` and `vm_os_sku` which is configured with:

- Two Public IP addresses (one for each VM)
- Opens up port 3389 for RDP access using the password as shown

```hcl 
  module "linuxservers" {
    source              = "Azure/compute/azurerm"
    resource_group_name = "terraform-advancedvms"
    location            = "westus2"
    vm_hostname         = "mylinuxvm"
    nb_public_ip        = "0"
    remote_port         = "22"
    nb_instances        = "2"
    vm_os_publisher     = "Canonical"
    vm_os_offer         = "UbuntuServer"
    vm_os_sku           = "14.04.2-LTS"
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
    boot_diagnostics    = "true"
    delete_os_disk_on_termination = "true"
    data_disk           = "true"
    data_disk_size_gb   = "64"
    data_sa_type        = "Premium_LRS"
    tags                = {
                            environment = "dev"
                            costcenter  = "it"
                          }
  }

  module "windowsservers" {
    source              = "Azure/compute/azurerm"
    resource_group_name = "terraform-advancedvms"
    location            = "westus2"
    vm_hostname         = "mywinvm"
    admin_password      = "ComplxP@ssw0rd!"
    public_ip_dns       = ["winterravmip","winterravmip1"]
    nb_public_ip        = "2"
    remote_port         = "3389"
    nb_instances        = "2"
    vm_os_publisher     = "MicrosoftWindowsServer"
    vm_os_offer         = "WindowsServer"
    vm_os_sku           = "2012-R2-Datacenter"
    vm_size             = "Standard_DS2_V2"
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  }

  module "network" {
    source              = "Azure/network/azurerm"
    version             = "~> 1.1.1"
    location            = "westus2"
    allow_rdp_traffic   = "true"
    allow_ssh_traffic   = "true"
    resource_group_name = "terraform-advancedvms"
  }

  output "linux_vm_private_ips" {
    value = "${module.linuxservers.network_interface_private_ip}"
  }

  output "windows_vm_public_name"{
    value = "${module.windowsservers.public_ip_dns_name}"
  }

  output "windows_vm_public_ip" {
    value = "${module.windowsservers.public_ip_address}"
  }

  output "windows_vm_private_ips" {
    value = "${module.windowsservers.network_interface_private_ip}"
  }

```

Test
-----

### Configurations
- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
- [Generate and add SSH Key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) Save the key in ~/.ssh/id_rsa.  This is not required for Windows deployments.

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native (Mac/Linux)

#### Prerequisites
- [Ruby **(~> 2.3)**](https://www.ruby-lang.org/en/downloads/)
- [Bundler **(~> 1.15)**](https://bundler.io/)
- [Terraform **(~> 0.11.0)**](https://www.terraform.io/downloads.html)

#### Quick Run

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

Then simply run it in local shell:
```sh
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

Authors
=======
Originally created by [David Tesar](http://github.com/dtzar)

License
=======

[MIT](LICENSE)
