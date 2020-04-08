provider "azurerm" {
  features {}
}

resource "random_id" "ip_dns" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  name     = "host${random_id.ip_dns.hex}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "host${random_id.ip_dns.hex}-vn"
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "host${random_id.ip_dns.hex}-sn-1"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "host${random_id.ip_dns.hex}-sn-2"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "subnet3" {
  name                 = "host${random_id.ip_dns.hex}-sn-3"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefix       = "10.0.3.0/24"
}

module "ubuntuservers" {
  source                        = "../../"
  vm_hostname                   = "${random_id.ip_dns.hex}-u"
  resource_group_name           = azurerm_resource_group.test.name
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  vm_os_simple                  = var.vm_os_simple_1
  public_ip_dns                 = ["ubuntusimplevmips-${random_id.ip_dns.hex}"]
  vnet_subnet_id                = azurerm_subnet.subnet1.id
  allocation_method             = "Static"
  enable_accelerated_networking = true
  vm_size                       = "Standard_DS2_V2"
  nb_data_disk                  = 2
  enable_ssh_key                = false
}

module "debianservers" {
  source              = "../../"
  vm_hostname         = "${random_id.ip_dns.hex}-d"
  resource_group_name = azurerm_resource_group.test.name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  custom_data         = var.custom_data
  vm_os_simple        = var.vm_os_simple_2
  public_ip_dns       = ["debiansimplevmips-${random_id.ip_dns.hex}"] // change to a unique name per datacenter region
  vnet_subnet_id      = azurerm_subnet.subnet2.id
  allocation_method   = "Static"
  enable_ssh_key      = true
}

module "windowsservers" {
  source              = "../../"
  vm_hostname         = "${random_id.ip_dns.hex}-w" // line can be removed if only one VM module per resource group
  resource_group_name = azurerm_resource_group.test.name
  is_windows_image    = true
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["winsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = azurerm_subnet.subnet3.id
}