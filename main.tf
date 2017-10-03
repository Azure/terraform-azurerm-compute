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

resource "azurerm_storage_account" "vm-sa" {
  count = "${var.boot_diagnostics == "true" ? 1 : 0}"
  name = "${lower(replace(var.vm_hostname,"/[[:^alpha:]]/",""))}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
  location = "${var.location}"
  account_type = "${var.storage_account_type}"
  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm-linux" {
  count = "${contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer") ? 0 : var.nb_instances}"
  name                  = "${var.vm_hostname}${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.vm.name}"
  availability_set_id   = "${azurerm_availability_set.vm.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher)}"
    offer     = "${coalesce(var.vm_os_offer, module.os.calculated_value_os_offer)}"
    sku       = "${coalesce(var.vm_os_sku, module.os.calculated_value_os_sku)}"
    version   = "${var.vm_os_version}"
  }

  storage_os_disk {
    name          = "osdisk-${var.vm_hostname}-${count.index}"
    create_option = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }
  
  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }
  boot_diagnostics {
    enabled = "${var.boot_diagnostics}"
    storage_uri = "${azurerm_storage_account.vm-sa.primary_blob_endpoint}"
  }
}

resource "azurerm_virtual_machine" "vm-windows" {
  count = "${contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer") ? var.nb_instances : 0}"
  name                  = "${var.vm_hostname}${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.vm.name}"
  availability_set_id   = "${azurerm_availability_set.vm.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher)}"
    offer     = "${coalesce(var.vm_os_offer, module.os.calculated_value_os_offer)}"
    sku       = "${coalesce(var.vm_os_sku, module.os.calculated_value_os_sku)}"
    version   = "${var.vm_os_version}"
  }

  storage_os_disk {
    name              = "osdisk${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
  boot_diagnostics {
    enabled = "${var.boot_diagnostics}"
    storage_uri = "${azurerm_storage_account.vm-sa.primary_blob_endpoint}"
  }
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_hostname}avset"
  location                     = "${azurerm_resource_group.vm.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "vm" {
  name                         = "${var.vm_hostname}-publicIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  public_ip_address_allocation = "${var.public_ip_address_allocation}"
  domain_name_label            = "${var.public_ip_dns}"
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
  name                = "nic-${var.vm_hostname}-${count.index}"
  location            = "${azurerm_resource_group.vm.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
  network_security_group_id = "${azurerm_network_security_group.vm.id}"

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = "${var.vnet_subnet_id}"
    private_ip_address_allocation           = "Dynamic"
    public_ip_address_id                    = "${count.index == 0 ? azurerm_public_ip.vm.id : ""}"
  }
}
