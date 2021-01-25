# See https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples/virtual-machines/windows

module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}
resource "azurerm_resource_group" "vm" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}
data "azurerm_subnet" "vm" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.vnet_resource_group
}

resource "azurerm_windows_virtual_machine" "vm" {
  count                    = var.nb_instances
  name                     = "${var.vm_hostname}-${count.index}"
  resource_group_name      = azurerm_resource_group.vm.name
  location                 = coalesce(var.location, azurerm_resource_group.vm.location)
  size                     = var.vm_size
  network_interface_ids    = [element(azurerm_network_interface.vm.*.id, count.index)]
  license_type             = var.license_type
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  timezone                 = "Eastern Standard Time"
  enable_automatic_updates = var.automatic_updates ? true : false
  custom_data              = var.custom_data

  os_disk {
    name                 = "osdisk-${var.vm_hostname}-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  boot_diagnostics {}


  tags = local.tags
}

resource "azurerm_managed_disk" "vm" {
  count                = var.data_disk ? 1 : 0
  name                 = "datadisk-${var.vm_hostname}-${count.index}"
  resource_group_name  = azurerm_resource_group.vm.name
  location             = azurerm_resource_group.vm.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm" {
  count              = var.data_disk ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.vm[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[count.index].id
  lun                = count.index + 10
  caching            = "ReadWrite"
}

resource "azurerm_public_ip" "vm" {
  count               = var.nb_public_ip
  name                = "pip-${var.vm_hostname}-${count.index}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = coalesce(var.location, azurerm_resource_group.vm.location)
  allocation_method   = var.allocation_method
  sku                 = var.public_ip_sku
  domain_name_label   = element(var.public_ip_dns, count.index)
  tags                = local.tags
}

# Get the public IP dynamic ip address after creation
data "azurerm_public_ip" "vm" {
  count               = var.nb_public_ip
  name                = azurerm_public_ip.vm[count.index].name
  resource_group_name = azurerm_resource_group.vm.name
  depends_on          = [azurerm_windows_virtual_machine.vm]
}

resource "azurerm_network_security_group" "vm" {
  name                = "nsg-${var.vm_hostname}"
  resource_group_name = azurerm_resource_group.vm.name
  location            = coalesce(var.location, azurerm_resource_group.vm.location)

  tags = local.tags
}

resource "azurerm_network_security_rule" "vm" {
  count                       = var.remote_port != "" ? 1 : 0
  name                        = "allow_remote_${coalesce(var.remote_port, module.os.calculated_remote_port)}_in_all"
  resource_group_name         = azurerm_resource_group.vm.name
  description                 = "Allow remote protocol in from all locations"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = coalesce(var.remote_port, module.os.calculated_remote_port)
  source_address_prefixes     = var.source_address_prefixes
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_network_interface" "vm" {
  count                         = var.nb_instances
  name                          = "nic-${var.vm_hostname}-${count.index}"
  resource_group_name           = azurerm_resource_group.vm.name
  location                      = coalesce(var.location, azurerm_resource_group.vm.location)
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ip-${var.vm_hostname}-${count.index}"
    subnet_id                     = data.azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""
  }

  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "vm" {
  count                     = var.nb_instances
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_virtual_machine_extension" "join-domain" {
  count                = var.nb_instances
  name                 = "JoinDomain"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id

  settings = <<SETTINGS
    {
        "Name": "${var.active_directory_domain_name}",
        "OUPath": "OU=Servers,OU=Azure Canada,DC=agri-marche,DC=local",
        "User": "${var.active_directory_username}@${var.active_directory_domain_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.active_directory_password}"
    }
SETTINGS
  depends_on         = [azurerm_windows_virtual_machine.vm]
}

# For set the timezone with Powershell since the timezone parameter of the azurerm_windows_virtual_machine resource does not always work
resource "azurerm_virtual_machine_extension" "set-timezone" {
  count                = var.nb_instances
  name                 = "SetTimezone"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"Set-TimeZone -Id 'Eastern Standard Time' \""
  }
SETTINGS
}
