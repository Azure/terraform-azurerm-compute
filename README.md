Deploys 1+ Virtual Machines to your provided VNet
=================================================

This Terraform module deploys Virtual Machines in Azure with the following characteristics:

- Ability to specify a simple string to get the latest marketplace image using `var.vm_os_simple`
- All VMs use managed disks
- Network Security Group (NSG) created and only if `var.remote_port` specified, then remote access rule created and opens this port to all nics
- VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.vnet_subnet_id`.
- Public IP is created and attached only to the first VM's nic.  Once into this VM, connection can be make to the other vms using the private ip on the VNet.


Usage
-----

Provisions 2 Windows 2016 Datacenter Server VMs using `vm_os_simple` to a new VNet and opens up port 3389 for RDP access:

```hcl
  module "mycompute" {
    source = "Azure/compute/azurerm"
    resource_group_name = "mycompute"
    location = "East US 2"
    admin_password = ComplxP@ssw0rd!
    vm_os_simple = "WindowsServer"
    public_ip_dns = "mywindowsservers225"
    remote_port = "3389"
    nb_instances = 2
    vnet_subnet_id = "${module.network.vnet_subnets[0]}"
  }

  module "network" {
    source = "Azure/network/azurerm"
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
    source              = "Azure/compute/azurerm"
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
    source = "Azure/compute/azurerm"
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
