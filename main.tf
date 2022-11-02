module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

locals {
  ssh_keys = [for f in compact(concat([var.ssh_key], var.extra_ssh_keys)) : f if fileexists(f)]
}

# tflint-ignore: terraform_naming_convention
resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 6
}

# tflint-ignore: terraform_naming_convention
resource "azurerm_storage_account" "vm-sa" {
  count = var.boot_diagnostics ? 1 : 0

  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  location                 = coalesce(var.location, data.azurerm_resource_group.vm.location)
  name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
  resource_group_name      = data.azurerm_resource_group.vm.name
  tags                     = var.tags
}

# tflint-ignore: terraform_naming_convention
resource "azurerm_virtual_machine" "vm-linux" {
  count = !contains(tolist([
    var.vm_os_simple, var.vm_os_offer
  ]), "WindowsServer") && !var.is_windows_image ? var.nb_instances : 0

  location = coalesce(var.location, data.azurerm_resource_group.vm.location)
  name     = "${var.vm_hostname}-vmLinux-${count.index}"
  # tflint-ignore: terraform_count_index_usage
  network_interface_ids            = [azurerm_network_interface.vm[count.index].id]
  resource_group_name              = data.azurerm_resource_group.vm.name
  vm_size                          = var.vm_size
  availability_set_id              = azurerm_availability_set.vm.id
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  tags                             = var.tags

  storage_os_disk {
    create_option     = "FromImage"
    name              = "osdisk-${var.vm_hostname}-${count.index}"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }
  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []

    content {
      type = var.identity_type
    }
  }
  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []

    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }
  os_profile {
    admin_username = var.admin_username
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_password = var.admin_password
    custom_data    = var.custom_data
  }
  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key

    dynamic "ssh_keys" {
      for_each = var.enable_ssh_key ? local.ssh_keys : []

      content {
        key_data = file(ssh_keys.value)
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      }
    }
    dynamic "ssh_keys" {
      for_each = var.enable_ssh_key ? var.ssh_key_values : []

      content {
        key_data = ssh_keys.value
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      }
    }
  }
  dynamic "os_profile_secrets" {
    for_each = var.os_profile_secrets

    content {
      source_vault_id = os_profile_secrets.value["source_vault_id"]

      vault_certificates {
        certificate_url = os_profile_secrets.value["certificate_url"]
      }
    }
  }
  dynamic "storage_data_disk" {
    for_each = range(var.nb_data_disk)

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.value
      name              = "${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.value}"
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }
  dynamic "storage_data_disk" {
    for_each = var.extra_disks

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.key + var.nb_data_disk
      name              = "${var.vm_hostname}-extradisk-${count.index}-${storage_data_disk.value.name}"
      disk_size_gb      = storage_data_disk.value.size
      managed_disk_type = var.data_sa_type
    }
  }
  storage_image_reference {
    id        = var.vm_os_id
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }
}

# tflint-ignore: terraform_naming_convention
resource "azurerm_virtual_machine" "vm-windows" {
  count = (var.is_windows_image || contains(tolist([
    var.vm_os_simple, var.vm_os_offer
  ]), "WindowsServer")) ? var.nb_instances : 0

  location = coalesce(var.location, data.azurerm_resource_group.vm.location)
  name     = "${var.vm_hostname}-vmWindows-${count.index}"
  # tflint-ignore: terraform_count_index_usage
  network_interface_ids         = [azurerm_network_interface.vm[count.index].id]
  resource_group_name           = data.azurerm_resource_group.vm.name
  vm_size                       = var.vm_size
  availability_set_id           = azurerm_availability_set.vm.id
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  license_type                  = var.license_type
  tags                          = var.tags

  storage_os_disk {
    create_option     = "FromImage"
    name              = "${var.vm_hostname}-osdisk-${count.index}"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }
  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []

    content {
      type = var.identity_type
    }
  }
  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []

    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }
  os_profile {
    admin_username = var.admin_username
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_password = var.admin_password
  }
  dynamic "os_profile_secrets" {
    for_each = var.os_profile_secrets

    content {
      source_vault_id = os_profile_secrets.value["source_vault_id"]

      vault_certificates {
        certificate_url   = os_profile_secrets.value["certificate_url"]
        certificate_store = os_profile_secrets.value["certificate_store"]
      }
    }
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  dynamic "storage_data_disk" {
    for_each = range(var.nb_data_disk)

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.value
      name              = "${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.value}"
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }
  dynamic "storage_data_disk" {
    for_each = var.extra_disks

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.key + var.nb_data_disk
      name              = "${var.vm_hostname}-extradisk-${count.index}-${storage_data_disk.value.name}"
      disk_size_gb      = storage_data_disk.value.size
      managed_disk_type = var.data_sa_type
    }
  }
  storage_image_reference {
    id        = var.vm_os_id
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }
}

resource "azurerm_availability_set" "vm" {
  location                     = coalesce(var.location, data.azurerm_resource_group.vm.location)
  name                         = "${var.vm_hostname}-avset"
  resource_group_name          = data.azurerm_resource_group.vm.name
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  tags                         = var.tags
}

resource "azurerm_public_ip" "vm" {
  count = var.nb_public_ip

  allocation_method   = var.allocation_method
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
  name                = "${var.vm_hostname}-pip-${count.index}"
  resource_group_name = data.azurerm_resource_group.vm.name
  domain_name_label   = element(var.public_ip_dns, count.index)
  sku                 = var.public_ip_sku
  tags                = var.tags
}

# Dynamic public ip address will be got after it's assigned to a vm
data "azurerm_public_ip" "vm" {
  count = var.nb_public_ip

  # tflint-ignore: terraform_count_index_usage
  name                = azurerm_public_ip.vm[count.index].name
  resource_group_name = data.azurerm_resource_group.vm.name

  depends_on = [azurerm_virtual_machine.vm-linux, azurerm_virtual_machine.vm-windows]
}

resource "azurerm_network_security_group" "vm" {
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
  name                = "${var.vm_hostname}-nsg"
  resource_group_name = data.azurerm_resource_group.vm.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "vm" {
  count = var.remote_port != "" ? 1 : 0

  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow_remote_${coalesce(var.remote_port, module.os.calculated_remote_port)}_in_all"
  network_security_group_name = azurerm_network_security_group.vm.name
  priority                    = 101
  protocol                    = "Tcp"
  resource_group_name         = data.azurerm_resource_group.vm.name
  description                 = "Allow remote protocol in from all locations"
  destination_address_prefix  = "*"
  destination_port_range      = coalesce(var.remote_port, module.os.calculated_remote_port)
  source_address_prefixes     = var.source_address_prefixes
  source_port_range           = "*"
}

resource "azurerm_network_interface" "vm" {
  count = var.nb_instances

  location                      = coalesce(var.location, data.azurerm_resource_group.vm.location)
  name                          = "${var.vm_hostname}-nic-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  enable_accelerated_networking = var.enable_accelerated_networking
  tags                          = var.tags

  ip_configuration {
    name                          = "${var.vm_hostname}-ip-${count.index}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, tolist([
      ""
    ])), count.index) : ""
    subnet_id = var.vnet_subnet_id
  }

}

resource "azurerm_network_interface_security_group_association" "test" {
  count = var.nb_instances
  # tflint-ignore: terraform_count_index_usage
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}
