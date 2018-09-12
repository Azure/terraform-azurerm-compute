provider "random" {
  version = "~> 1.0"
}

resource "random_id" "ip_dns" {
  byte_length = 8
}

module "ubuntuservers" {
  source                       = "../../"
  location                     = "${var.location}"
  admin_username               = "${var.admin_username}"
  admin_password               = "${var.admin_password}"
  vm_os_simple                 = "${var.vm_os_simple_1}"
  public_ip_dns                = ["ubuntusimplevmips-${random_id.ip_dns.hex}"]
  vnet_subnet_id               = "${module.network.vnet_subnets[0]}"
  ssh_key                      = "${var.ssh_key}"
  resource_group_name          = "${var.resource_group_name}-${random_id.ip_dns.hex}"
  public_ip_address_allocation = "static"
}

module "debianservers" {
  source                       = "../../"
  location                     = "${var.location}"
  vm_hostname                  = "mylinvm"
  admin_username               = "${var.admin_username}"
  admin_password               = "${var.admin_password}"
  vm_os_simple                 = "${var.vm_os_simple_2}"
  public_ip_dns                = ["debiansimplevmips-${random_id.ip_dns.hex}"]        // change to a unique name per datacenter region
  vnet_subnet_id               = "${module.network.vnet_subnets[0]}"
  ssh_key                      = "${var.ssh_key}"
  resource_group_name          = "${var.resource_group_name}-${random_id.ip_dns.hex}"
  public_ip_address_allocation = "static"
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "2.0.0"
  location            = "westus2"
  resource_group_name = "${var.resource_group_name}-${random_id.ip_dns.hex}"
}
