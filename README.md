# terraform-azurerm-compute-windows

## Deploys 1+ Virtual Machines to your provided VNet

This Terraform module deploys Virtual Machines in Azure with the following characteristics:

- Ability to specify a simple string to get the [latest marketplace image](https://docs.microsoft.com/cli/azure/vm/image?view=azure-cli-latest) using `var.vm_os_simple`
- Automatically create a resource group for each VM set created using `var.resource_group_name`
- All VMs use [managed disks](https://azure.microsoft.com/services/managed-disks/)
- Network Security Group (NSG) created with a single remote access rule which opens `var.remote_port` port or auto calculated port number if using `var.vm_os_simple` to all nics
- VM nics attached to a single virtual network subnet of your choice via `var.subnet_name`, `var.virtual_network_name` and `var.vnet_resource_group`.
- Control the number of Public IP addresses assigned to VMs via `var.nb_public_ip`. Create and attach one Public IP per VM up to the number of VMs or create NO public IPs via setting `var.nb_public_ip` to `0`.
- Control SKU and Allocation Method of the public IPs via `var.allocation_method` and `var.public_ip_sku`.
- Tags need to be defined in a certain format using `var.tags`.

## Usage in Terraform 0.14
```hcl
provider "azurerm" {
  features {}
}

module "windowsservers" {
  source              = "module path/name"
  resource_group_name = "rg-resource-group-name-test"
  vm_hostname         = "vm-test"
  admin_password      = "ComplxP@ssw0rd!"
  vm_os_simple        = "WindowsServer"    
  tags                = {
                          CostCenter = "IT"
                          App = "Test"
                          Environment = "test"
                          Importance = "low"
                        }
  
}
```

## Authors

Originally created by [Régis Tremblay Lefrançois](http://github.com/rtlefrancois)

## License

[MIT](LICENSE)
