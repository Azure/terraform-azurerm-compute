resource "random_id" "ip_dns" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "host${random_id.ip_dns.hex}-rg"
}

locals {
  vnet_address_space = "10.0.0.0/16"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [local.vnet_address_space]
  location            = var.location_alt
  name                = "host${random_id.ip_dns.hex}-vn"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "subnet" {
  count = 3

  # tflint-ignore: terraform_count_index_usage
  address_prefixes     = [cidrsubnet(local.vnet_address_space, 8, count.index)]
  name                 = "host${random_id.ip_dns.hex}-sn-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_user_assigned_identity" "vm" {
  location            = azurerm_resource_group.test.location
  name                = "host${random_id.ip_dns.hex}-id"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_user_assigned_identity" "storage_account" {
  location            = azurerm_resource_group.test.location
  name                = "storage-account-${random_id.ip_dns.hex}-id"
  resource_group_name = azurerm_resource_group.test.name
}

locals {
  ubuntu_ssh_keys = fileexists("~/.ssh/id_rsa.pub") ? [] : ["monica_id_rsa.pub"]
}

resource "random_password" "admin_password" {
  length      = 20
  lower       = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  numeric     = true
  special     = true
  upper       = true
}

locals {
  admin_password = coalesce(var.admin_password, random_password.admin_password.result)
}

module "ubuntuservers" {
  source                        = "../.."
  vm_hostname                   = "${random_id.ip_dns.hex}-u"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = var.location_alt
  admin_username                = var.admin_username
  admin_password                = local.admin_password
  vm_os_simple                  = var.vm_os_simple_1
  public_ip_dns                 = ["ubuntusimplevmips-${random_id.ip_dns.hex}"]
  vnet_subnet_id                = azurerm_subnet.subnet[0].id
  allocation_method             = "Static"
  public_ip_sku                 = "Standard"
  enable_accelerated_networking = true
  delete_os_disk_on_termination = true
  ssh_key                       = fileexists("~/.ssh/id_rsa.pub") ? "~/.ssh/id_rsa.pub" : ""
  extra_ssh_keys                = local.ubuntu_ssh_keys
  vm_size                       = "Standard_DS2_V2"
  nb_data_disk                  = 2
  nested_data_disks             = false
  identity_type                 = "UserAssigned"
  identity_ids                  = [azurerm_user_assigned_identity.vm.id]
  os_profile_secrets = [
    {
      source_vault_id = azurerm_key_vault.test.id
      certificate_url = azurerm_key_vault_certificate.test.secret_id
    }
  ]
}

module "debianservers" {
  source              = "../.."
  vm_hostname         = "${random_id.ip_dns.hex}-d"
  resource_group_name = azurerm_resource_group.test.name
  location            = var.location_alt
  admin_username      = var.admin_username
  admin_password      = local.admin_password
  custom_data         = var.custom_data
  vm_os_simple        = var.vm_os_simple_2
  public_ip_dns       = ["debiansimplevmips-${random_id.ip_dns.hex}"]
  # change to a unique name per datacenter region
  vnet_subnet_id                   = azurerm_subnet.subnet[1].id
  allocation_method                = "Static"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  enable_ssh_key                   = true
  ssh_key                          = fileexists("~/.ssh/id_rsa.pub") ? "~/.ssh/id_rsa.pub" : ""
  extra_ssh_keys                   = ["monica_id_rsa.pub"]
  extra_disks = [
    {
      size = 5
      name = "extra1"
    },
    {
      size = 5
      name = "extra2"
    }
  ]
  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.vm.id]
}

resource "random_string" "storage_account" {
  length      = 16
  lower       = true
  min_lower   = 1
  min_numeric = 1
  numeric     = true
  special     = false
  upper       = false
}

resource "azurerm_storage_account" "debian2" {
  account_replication_type      = "LRS"
  account_tier                  = "Standard"
  location                      = var.location_alt
  name                          = "bootdiag${random_string.storage_account.result}"
  resource_group_name           = azurerm_resource_group.test.name
  account_kind                  = "StorageV2"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.des_key.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_account.id
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_account.id]
  }
  network_rules {
    default_action = "Deny"
  }
  queue_properties {
    logging {
      delete                = true
      read                  = true
      version               = "1.0"
      write                 = true
      retention_policy_days = 1
    }
  }

  depends_on = [azurerm_key_vault_access_policy.storage_account]
}

resource "azurerm_network_security_group" "external_nsg" {
  location            = var.location_alt
  name                = "${azurerm_resource_group.test.name}-nsg"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "vm" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow_remote_ssh"
  network_security_group_name = azurerm_network_security_group.external_nsg.name
  priority                    = 101
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.test.name
  description                 = "Allow remote protocol ssh"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  source_address_prefix       = local.public_ip
  source_port_range           = "*"
}

module "debianservers2" {
  source                          = "../.."
  vm_hostname                     = "${random_id.ip_dns.hex}-d2"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = var.location_alt
  admin_username                  = var.admin_username
  allocation_method               = "Static"
  as_platform_fault_domain_count  = 3
  as_platform_update_domain_count = 5
  vm_os_simple                    = var.vm_os_simple_2
  vnet_subnet_id                  = azurerm_subnet.subnet[1].id
  enable_ssh_key                  = true
  external_boot_diagnostics_storage = {
    uri = azurerm_storage_account.debian2.primary_blob_endpoint
  }
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  identity_type                    = "UserAssigned"
  identity_ids                     = [azurerm_user_assigned_identity.vm.id]
  public_ip_sku                    = "Standard"
  ssh_key                          = ""
  ssh_key_values                   = [file("${path.module}/monica_id_rsa.pub")]
  network_security_group = {
    id = azurerm_network_security_group.external_nsg.id
  }
  # To test `var.zone` please uncomment the line below.
  #  zone                             = "2"
}

module "windowsservers" {
  source              = "../.."
  vm_hostname         = "${random_id.ip_dns.hex}-w" # line can be removed if only one VM module per resource group
  resource_group_name = azurerm_resource_group.test.name
  location            = var.location_alt
  is_windows_image    = true
  admin_username      = var.admin_username
  admin_password      = local.admin_password
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["winsimplevmips-${random_id.ip_dns.hex}"] # change to a unique name per datacenter region
  vnet_subnet_id      = azurerm_subnet.subnet[2].id
  license_type        = var.license_type
  identity_type       = "UserAssigned"
  identity_ids        = [azurerm_user_assigned_identity.vm.id]
  nb_data_disk        = 1
  nested_data_disks   = false
  os_profile_secrets = [
    {
      source_vault_id   = azurerm_key_vault.test.id
      certificate_url   = azurerm_key_vault_certificate.test.secret_id
      certificate_store = "My"
    }
  ]
}
