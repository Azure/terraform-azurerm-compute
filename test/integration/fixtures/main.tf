provider "random" {
  version = "~> 1.0"
}

resource "random_id" "ip_dns" {
  byte_length = 8
}

module "linuxservers" {
  source                       = "../../../"
  location                     = "${var.location}"
  vm_os_simple                 = "${var.vm_os_simple}"
  public_ip_address_allocation = "static"
  public_ip_dns                = ["linuxserver-${random_id.ip_dns.hex}"]
  vnet_subnet_id               = "${module.network.vnet_subnets[0]}"
  ssh_key                      = "${var.ssh_key}"
  resource_group_name          = "${var.resource_group_name}"
}

module "network" {
  version             = "2.0.0"
  source              = "Azure/network/azurerm"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}
