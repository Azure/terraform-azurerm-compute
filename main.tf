module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

data "azurerm_resource_group" "vm" {
  count = var.location == null ? 1 : 0

  name = var.resource_group_name
}

locals {
  location = var.location == null ? data.azurerm_resource_group.vm[0].location : var.location
  ssh_keys = compact(concat([var.ssh_key], var.extra_ssh_keys))
}

moved {
  from = random_id.vm-sa
  to   = random_id.vm_sa
}

resource "random_id" "vm_sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 6
}

moved {
  from = azurerm_storage_account.vm-sa
  to   = azurerm_storage_account.vm_sa
}

resource "azurerm_storage_account" "vm_sa" {
  count = var.boot_diagnostics && var.external_boot_diagnostics_storage == null ? 1 : 0

  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  location                 = local.location
  name                     = "bootdiag${lower(random_id.vm_sa.hex)}"
  resource_group_name      = var.resource_group_name
  tags                     = var.tags
}

moved {
  from = azurerm_virtual_machine.vm-linux
  to   = azurerm_virtual_machine.vm_linux
}

resource "azurerm_virtual_machine" "vm_linux" {
  count = !local.is_windows ? var.nb_instances : 0

  location                         = local.location
  name                             = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "vmLinux"]) : join("-", [var.vm_hostname, "vmLinux", count.index])
  network_interface_ids            = [element(azurerm_network_interface.vm[*].id, count.index)]
  resource_group_name              = var.resource_group_name
  vm_size                          = var.vm_size
  availability_set_id              = try(azurerm_availability_set.vm[0].id, null)
  delete_data_disks_on_termination = var.delete_data_disks_on_termination
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  tags                             = var.tags
  zones                            = var.zone == null ? null : [var.zone]

  storage_os_disk {
    create_option     = "FromImage"
    name              = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "osdisk"]) : join("-", ["osdisk", var.vm_hostname, count.index])
    caching           = "ReadWrite"
    disk_size_gb      = var.storage_os_disk_size_gb
    managed_disk_type = var.storage_account_type
  }
  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? try(var.external_boot_diagnostics_storage.uri, join(",", azurerm_storage_account.vm_sa[*].primary_blob_endpoint)) : ""
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
  dynamic "plan" {
    for_each = var.is_marketplace_image ? ["plan"] : []

    content {
      name      = var.vm_os_sku
      product   = var.vm_os_offer
      publisher = var.vm_os_publisher
    }
  }
  dynamic "storage_data_disk" {
    for_each = local.nested_data_disk_list

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.value
      name              = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "datadisk", storage_data_disk.value]) : join("-", [var.vm_hostname, "datadisk", count.index, storage_data_disk.value])
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }
  dynamic "storage_data_disk" {
    for_each = local.nested_extra_data_disk_list

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.key + var.nb_data_disk
      name              = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "extradisk", storage_data_disk.value.name]) : join("-", [var.vm_hostname, "extradisk", count.index, storage_data_disk.value.name])
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

  lifecycle {
    precondition {
      condition     = !var.is_marketplace_image || (var.vm_os_offer != null && var.vm_os_publisher != null && var.vm_os_sku != null)
      error_message = "`var.vm_os_offer`, `vm_os_publisher` and `var.vm_os_sku` are required when `var.is_marketplace_image` is `true`."
    }
    precondition {
      condition     = var.nested_data_disks || var.delete_data_disks_on_termination != true
      error_message = "`var.nested_data_disks` must be `true` when `var.delete_data_disks_on_termination` is `true`, because when you declare data disks via separate managed disk resource, you might want to preserve the data while recreating the vm instance."
    }
  }
}

moved {
  from = azurerm_virtual_machine.vm-windows
  to   = azurerm_virtual_machine.vm_windows
}

resource "azurerm_virtual_machine" "vm_windows" {
  count = local.is_windows ? var.nb_instances : 0

  location                      = local.location
  name                          = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "vmWindows"]) : join("-", [var.vm_hostname, "vmWindows", count.index])
  network_interface_ids         = [element(azurerm_network_interface.vm[*].id, count.index)]
  resource_group_name           = var.resource_group_name
  vm_size                       = var.vm_size
  availability_set_id           = try(azurerm_availability_set.vm[0].id, null)
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  license_type                  = var.license_type
  tags                          = var.tags
  zones                         = var.zone == null ? null : [var.zone]

  storage_os_disk {
    create_option     = "FromImage"
    name              = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "osdisk"]) : join("-", [var.vm_hostname, "osdisk", count.index])
    caching           = "ReadWrite"
    disk_size_gb      = var.storage_os_disk_size_gb
    managed_disk_type = var.storage_account_type
  }
  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm_sa[*].primary_blob_endpoint) : ""
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
  dynamic "plan" {
    for_each = var.is_marketplace_image ? ["plan"] : []

    content {
      name      = var.vm_os_sku
      product   = var.vm_os_offer
      publisher = var.vm_os_publisher
    }
  }
  dynamic "storage_data_disk" {
    for_each = local.nested_data_disk_list

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.value
      name              = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "datadisk", storage_data_disk.value]) : join("-", [var.vm_hostname, "datadisk", count.index, storage_data_disk.value])
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }
  dynamic "storage_data_disk" {
    for_each = local.nested_extra_data_disk_list

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.key + var.nb_data_disk
      name              = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "extradisk", storage_data_disk.value.name]) : join("-", [var.vm_hostname, "extradisk", count.index, storage_data_disk.value.name])
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

  lifecycle {
    precondition {
      condition     = !var.is_marketplace_image || (var.vm_os_offer != null && var.vm_os_publisher != null && var.vm_os_sku != null)
      error_message = "`var.vm_os_offer`, `vm_os_publisher` and `var.vm_os_sku` are required when `var.is_marketplace_image` is `true`."
    }
    precondition {
      condition     = var.nested_data_disks || var.delete_data_disks_on_termination != true
      error_message = "`var.nested_data_disks` must be `true` when `var.delete_data_disks_on_termination` is `true`, because when you declare data disks via separate managed disk resource, you might want to preserve the data while recreating the vm instance."
    }
  }
}

resource "azurerm_managed_disk" "vm_data_disk" {
  for_each = local.data_disk_map

  create_option          = "Empty"
  location               = local.location
  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  storage_account_type   = var.data_sa_type
  disk_encryption_set_id = var.managed_data_disk_encryption_set_id
  disk_size_gb           = var.data_disk_size_gb
  tags                   = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disk_attachments_linux" {
  for_each = local.data_disk_map_linux

  caching            = "ReadWrite"
  lun                = each.value.disk_number
  managed_disk_id    = azurerm_managed_disk.vm_data_disk[each.key].id
  virtual_machine_id = azurerm_virtual_machine.vm_linux[each.value.host_number].id
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disk_attachments_windows" {
  for_each = local.data_disk_map_windows

  caching            = "ReadWrite"
  lun                = each.value.disk_number
  managed_disk_id    = azurerm_managed_disk.vm_data_disk[each.key].id
  virtual_machine_id = azurerm_virtual_machine.vm_windows[each.value.host_number].id
}

resource "azurerm_managed_disk" "vm_extra_disk" {
  for_each = local.extra_disk_map

  create_option          = "Empty"
  location               = local.location
  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  storage_account_type   = var.data_sa_type
  disk_encryption_set_id = var.managed_data_disk_encryption_set_id
  disk_size_gb           = each.value.disk_size
  tags                   = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_extra_disk_attachments_linux" {
  for_each = local.extra_disk_map_linux

  caching            = "ReadWrite"
  lun                = var.nb_data_disk + each.value.disk_number
  managed_disk_id    = azurerm_managed_disk.vm_extra_disk[each.key].id
  virtual_machine_id = azurerm_virtual_machine.vm_linux[each.value.host_number].id
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_extra_disk_attachments_windows" {
  for_each = local.extra_disk_map_windows

  caching            = "ReadWrite"
  lun                = var.nb_data_disk + each.value.disk_number
  managed_disk_id    = azurerm_managed_disk.vm_extra_disk[each.key].id
  virtual_machine_id = azurerm_virtual_machine.vm_windows[each.value.host_number].id
}

resource "azurerm_availability_set" "vm" {
  count = (var.availability_set_enabled && (var.zone == null)) ? 1 : 0

  location                     = local.location
  name                         = "${var.vm_hostname}-avset"
  resource_group_name          = var.resource_group_name
  managed                      = true
  platform_fault_domain_count  = var.as_platform_fault_domain_count
  platform_update_domain_count = var.as_platform_update_domain_count
  tags                         = var.tags
}

resource "azurerm_public_ip" "vm" {
  count = var.nb_public_ip

  allocation_method   = var.allocation_method
  location            = local.location
  name                = "${var.vm_hostname}-pip-${count.index}"
  resource_group_name = var.resource_group_name
  domain_name_label   = element(var.public_ip_dns, count.index)
  sku                 = var.public_ip_sku
  tags                = var.tags
  zones               = var.zone == null ? null : [var.zone]

  # To solve issue [#107](https://github.com/Azure/terraform-azurerm-compute/issues/107) we add such block to make `azurerm_network_interface.vm`'s update happen first.
  # Issue #107's root cause is Terraform will try to execute deletion before update, once we tried to delete the public ip, it is still attached on the network interface.
  # Declare this `create_before_destroy` will defer this public ip resource's deletion after creation and update so we can fix the issue.
  lifecycle {
    create_before_destroy = true
  }
}

# Dynamic public ip address will be got after it's assigned to a vm
data "azurerm_public_ip" "vm" {
  count = var.nb_public_ip

  name                = azurerm_public_ip.vm[count.index].name
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_virtual_machine.vm_linux, azurerm_virtual_machine.vm_windows]
}

moved {
  from = azurerm_network_security_group.vm
  to   = azurerm_network_security_group.vm[0]
}

resource "azurerm_network_security_group" "vm" {
  count = var.network_security_group == null ? 1 : 0

  location            = local.location
  name                = "${var.vm_hostname}-nsg"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  network_security_group_id = var.network_security_group == null ? azurerm_network_security_group.vm[0].id : var.network_security_group.id
}

resource "azurerm_network_security_rule" "vm" {
  count = var.network_security_group == null && var.remote_port != "" ? 1 : 0

  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow_remote_${coalesce(var.remote_port, module.os.calculated_remote_port)}_in_all"
  network_security_group_name = azurerm_network_security_group.vm[0].name
  priority                    = 101
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  description                 = "Allow remote protocol in from all locations"
  destination_address_prefix  = "*"
  destination_port_range      = coalesce(var.remote_port, module.os.calculated_remote_port)
  source_address_prefixes     = var.source_address_prefixes
  source_port_range           = "*"
}

resource "azurerm_network_interface" "vm" {
  count = var.nb_instances

  location                      = local.location
  name                          = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "nic"]) : join("-", [var.vm_hostname, "nic", count.index])
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking
  tags                          = var.tags

  ip_configuration {
    name                          = var.group_by_vm_instance ? join("-", [var.vm_hostname, count.index, "ip"]) : join("-", [var.vm_hostname, "ip", count.index])
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = length(azurerm_public_ip.vm[*].id) > 0 ? element(concat(azurerm_public_ip.vm[*].id, tolist([
      ""
    ])), count.index) : ""
    subnet_id = var.vnet_subnet_id
  }
}

resource "azurerm_network_interface_security_group_association" "test" {
  count = var.nb_instances

  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = local.network_security_group_id
}

resource "azurerm_virtual_machine_extension" "extension" {
  count = var.vm_extension == null ? 0 : var.nb_instances

  name                        = var.vm_extension.name
  publisher                   = var.vm_extension.publisher
  type                        = var.vm_extension.type
  type_handler_version        = var.vm_extension.type_handler_version
  virtual_machine_id          = local.is_windows ? azurerm_virtual_machine.vm_windows[count.index].id : azurerm_virtual_machine.vm_linux[count.index].id
  auto_upgrade_minor_version  = var.vm_extension.auto_upgrade_minor_version
  automatic_upgrade_enabled   = var.vm_extension.automatic_upgrade_enabled
  failure_suppression_enabled = var.vm_extension.failure_suppression_enabled
  protected_settings          = var.vm_extension.protected_settings
  settings                    = var.vm_extension.settings
  tags                        = var.tags

  dynamic "protected_settings_from_key_vault" {
    for_each = var.vm_extension.protected_settings_from_key_vault == null ? [] : ["protected_settings_from_key_vault"]

    content {
      secret_url      = var.vm_extension.protected_settings_from_key_vault.secret_url
      source_vault_id = var.vm_extension.protected_settings_from_key_vault.source_vault_id
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.vm_extensions) == 0
      error_message = "`vm_extensions` cannot be used along with `vm_extension`."
    }
  }
}

resource "azurerm_virtual_machine_extension" "extensions" {
  # The `sensitive` inside `nonsensitive` is a workaround for https://github.com/terraform-linters/tflint-ruleset-azurerm/issues/229
  for_each = nonsensitive(sensitive(local.vm_extensions))

  name                        = each.value.value.name
  publisher                   = each.value.value.publisher
  type                        = each.value.value.type
  type_handler_version        = each.value.value.type_handler_version
  virtual_machine_id          = local.is_windows ? azurerm_virtual_machine.vm_windows[each.value.index].id : azurerm_virtual_machine.vm_linux[each.value.index].id
  auto_upgrade_minor_version  = each.value.value.auto_upgrade_minor_version
  automatic_upgrade_enabled   = each.value.value.automatic_upgrade_enabled
  failure_suppression_enabled = each.value.value.failure_suppression_enabled
  protected_settings          = each.value.value.protected_settings
  settings                    = each.value.value.settings
  tags                        = var.tags

  dynamic "protected_settings_from_key_vault" {
    for_each = each.value.value.protected_settings_from_key_vault == null ? [] : ["protected_settings_from_key_vault"]

    content {
      secret_url      = each.value.value.protected_settings_from_key_vault.secret_url
      source_vault_id = each.value.value.protected_settings_from_key_vault.source_vault_id
    }
  }

  lifecycle {
    precondition {
      condition     = var.vm_extension == null
      error_message = "`vm_extensions` cannot be used along with `vm_extension`."
    }
  }
}