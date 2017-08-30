provider "azurerm" {
    version = "~> 0.1"
}

module "os" {
  source = "./os"
  vm_os_simple = "${var.vm_os_simple}"
}

resource "azurerm_resource_group" "vm" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "vm${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.vm.name}"
  availability_set_id   = "${azurerm_availability_set.vm.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  count                 = "${var.nb_instances}"

  storage_image_reference {
    publisher = "${coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher)}"
    offer     = "${coalesce(var.vm_os_offer, module.os.calculated_value_os_offer)}"
    sku       = "${coalesce(var.vm_os_sku, module.os.calculated_value_os_sku)}"
    version   = "${var.vm_os_version}"
  }

  storage_os_disk {
    name          = "osdisk${count.index}"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
}

resource "azurerm_storage_account" "vm" {
  //name                = "${var.dns_name}stor"
  location            = "${azurerm_resource_group.vm.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
  account_type        = "${var.storage_account_type}"
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_hostname}avset"
  location                     = "${azurerm_resource_group.vm.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_security_group" "vm" {
  name                = "remote-access-nsg"
  location            = "${azurerm_resource_group.vm.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"

  security_rule {
    name                       = "allow_remote_in_all"
    description                = "Allow remote protocol in from all locations"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "${var.remote_port}"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm" {
  count               = "${var.nb_instances}"
  name                = "nic${count.index}"
  location            = "${azurerm_resource_group.vm.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
  network_security_group_id = "${azurerm_network_security_group.vm.id}"

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = "${module.tf-azurerm-vnet.azurerm_subnet_ids[0]}"
    private_ip_address_allocation           = "Dynamic"
  }
}