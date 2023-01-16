resource "random_id" "id" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "host${random_id.id.hex}-rg"
}

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.0.0"

  resource_group_name = azurerm_resource_group.test.name
  use_for_each        = true
  vnet_location       = azurerm_resource_group.test.location
  address_space       = ["192.168.0.0/24"]
  vnet_name           = "vnet-vm-${random_id.id.hex}"
  subnet_names        = ["subnet-compute"]
  subnet_prefixes     = ["192.168.0.0/28"]
}

module "ubuntuservers" {
  source                           = "../.."
  vm_hostname                      = "${random_id.id.hex}-u"
  resource_group_name              = azurerm_resource_group.test.name
  location                         = azurerm_resource_group.test.location
  admin_username                   = var.admin_username
  boot_diagnostics                 = false
  vm_os_simple                     = var.vm_os_simple
  vnet_subnet_id                   = module.vnet.vnet_subnets[0]
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  enable_ssh_key                   = true
  ssh_key                          = "monica_id_rsa.pub"
  storage_account_type             = "Standard_LRS"
  vm_size                          = "Standard_F2"
  nb_data_disk                     = 1
  vm_extensions = [
    {
      name                 = "hostname"
      publisher            = "Microsoft.Azure.Extensions",
      type                 = "CustomScript",
      type_handler_version = "2.0",
      settings             = "{\"commandToExecute\": \"hostname && uptime\"}",
    },
    {
      name                       = "AzureMonitorLinuxAgent"
      publisher                  = "Microsoft.Azure.Monitor",
      type                       = "AzureMonitorLinuxAgent",
      type_handler_version       = "1.21",
      auto_upgrade_minor_version = true
    },
  ]
}