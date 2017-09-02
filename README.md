Deploys 1+ Virtual Machines to your provided VNet
=================================================

This Terraform module deploys Virtual Machines in Azure with the following characteristics:

- Ability to specify a simple string to get the latest marketplace image using `var.vm_os_simple`
- All VMs use managed disks
- Network Security Group (NSG) created and only if `var.remote_port` specified, then remote access rule created and opens this port to all nics
- VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.vnet_subnet_id`.
- Public IP is created and attached only to the first VM's nic.  Once into this VM, connection can be make to the other vms using the private ip on the VNet.

Module Input Variables
----------------------

- `resource_group_name` - The name of the resource group in which the resources will be created. - default `compute`
- `location` - The Azure location where the resources will be created.
- `vnet_subnet_id` - The subnet id of the virtual network where the virtual machines will reside.
- `public_ip_dns` - Optional globally unique per datacenter region domain name label to apply to the public ip address. e.g. thisvar.varlocation.cloudapp.azure.com
- `admin_password` - The password of the administrator account. The password must comply with the complexity requirements for Azure virtual machines.
- `ssh_key` - The path on the local machine of the ssh public key in the case of a Linux deployment. - default `~/.ssh/id_rsa.pub`
- `remote_port` - Tcp port number to enable remote access to the nics on the vms via a NSG rule. Set to blank to disable.
- `admin_username` - The name of the administrator to access the machines part of the virtual machine scale set. - default `azureuser`
- `storage_account_type` - Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS. - default `Premium_LRS`
- `vm_size` - The initial size of the virtual machine that will be deployed. - default `Standard_DS1_V2`
- `nb_instances` - The number of instances that will be initially deployed in the virtual machine scale set. - default `1`
- `vm_hostname` - local name of the VM. - default `myvm`
- `vm_os_simple`- This variable allows to use a simple name to reference Linux or Windows operating systems. When used, you can ommit the `vm_os_publisher`, `vm_os_offer` and `vm_os_sku`. The supported values are: "UbuntuServer", "WindowsServer", "RHEL", "openSUSE-Leap", "CentOS", "Debian", "CoreOS" and "SLES".
- `vm_os_id` - The ID of the image that you want to deploy if you are using a custom image. When used, you can ommit the `vm_os_publisher`, `vm_os_offer` and `vm_os_sku`.
- `vm_os_publisher` - The name of the publisher of the image that you want to deploy, for example "Canonical" if you are not using the `vm_os_simple` or `vm_os_id` variables. 
- `vm_os_offer` - The name of the offer of the image that you want to deploy, for example "UbuntuServer" if you are not using the `vm_os_simple` or `vm_os_id` variables. 
- `vm_os_sku` - The sku of the image that you want to deploy, for example "14.04.2-LTS" if you are not using the `vm_os_simple` or `vm_os_id` variables. 
- `vm_os_version` - The version of the image that you want to deploy. - default `latest`
- `public_ip_address_allocation` - Defines how an IP address is assigned. Options are Static or Dynamic. - default `static`
- `tags` - A map of the tags to use on the resources that are deployed with this module.

Usage
-----

Provisions 2 Windows 2016 Datacenter Server VMs using `vm_os_simple` to a new VNet and opens up port 22 for SSH access with ~/.ssh/id_rsa.pub :

```hcl
  module "mycompute" {
    source = "github.com/Azure/terraform-azurerm-compute"
    resource_group_name = "mycompute"
    location = "East US 2"
    vm_os_simple = "Windows"
    public_ip_dns = "mywindowsservers225"
    remote_port = "3389"
    nb_instances = 2
    vnet_subnet_id = "${module.network.vnet_subnets[0]}"
  }

  module "network" {
    source = "github.com/Azure/terraform-azurerm-network"
    location = "East US 2"
    resource_group_name = "mycompute"
  }

  output "vm_public_name"{
    value = "${module.mycompute.public_ip_dns_name}"
  }

  output "vm_public_ip" {
    value = "${module.mycompute.public_ip_address}"
  }

  output "vm_private_ips" {
    value = "${module.mycompute.network_interface_private_ip}"
  }
}

```
Provisions 2 Ubuntu 14.04 Server VMs using  `vm_os_publisher`, `vm_os_offer` and `vm_os_sku` to a new VNet and opens up port 22 for SSH access with ~/.ssh/id_rsa.pub :

```hcl 
module "mycompute2" { 
    source              = "github.com/Azure/terraform-azurerm-compute"
    resource_group_name = "mycompute2"
    location            = "westus"
    public_ip_dns       = "myubuntuservers225"
    remote_port         = "22"
    nb_instances        = 2
    vm_os_publisher     = "Canonical"
    vm_os_offer         = "UbuntuServer"
    vm_os_sku           = "14.04.2-LTS"
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
    tags                = {
                            environment = "dev"
                            costcenter  = "it"
                          }
}
  module "network" {
    source = "github.com/Azure/terraform-azurerm-network"
    location = "westus"
    resource_group_name = "mycompute2"
  }

```

Outputs
=======

- `vm_ids`- Virtual machine ids created
- `network_security_group_id` - id of the security group provisioned
- `network_interface_ids` - ids of the vm nics provisoned
- `network_interface_private_ip` - private ip addresses of the vm nics
- `public_ip_id` - id of the public ip address provisoned
- `public_ip_address` - The actual ip address allocated for the resource.
- `public_ip_dns_name` - fqdn to connect to the first vm   provisioned.
- `availability_set_id` - id of the availability set where the vms are provisioned.

Authors
=======
Originally created by [David Tesar](http://github.com/dtzar)

License
=======

[MIT](LICENSE)
