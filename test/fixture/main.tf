provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
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
  location            = var.location_alt
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "host${random_id.ip_dns.hex}-sn-1"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "host${random_id.ip_dns.hex}-sn-2"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet3" {
  name                 = "host${random_id.ip_dns.hex}-sn-3"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  name = "host${random_id.ip_dns.hex}-id"
}

module "ubuntuservers" {
  source                        = "../../"
  vm_hostname                   = "${random_id.ip_dns.hex}-u"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = var.location_alt
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  vm_os_simple                  = var.vm_os_simple_1
  public_ip_dns                 = ["ubuntusimplevmips-${random_id.ip_dns.hex}"]
  vnet_subnet_id                = azurerm_subnet.subnet1.id
  allocation_method             = "Static"
  public_ip_sku                 = "Standard"
  enable_accelerated_networking = true
  vm_size                       = "Standard_DS2_V2"
  nb_data_disk                  = 2
  identity_type                 = "UserAssigned"
  identity_ids                  = [azurerm_user_assigned_identity.test.id]
  os_profile_secrets = [{
    source_vault_id = azurerm_key_vault.test.id
    certificate_url = azurerm_key_vault_certificate.test.secret_id
  }]

  depends_on = [azurerm_resource_group.test]
}

module "debianservers" {
  source              = "../../"
  vm_hostname         = "${random_id.ip_dns.hex}-d"
  resource_group_name = azurerm_resource_group.test.name
  location            = var.location_alt
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  custom_data         = var.custom_data
  vm_os_simple        = var.vm_os_simple_2
  public_ip_dns       = ["debiansimplevmips-${random_id.ip_dns.hex}"] // change to a unique name per datacenter region
  vnet_subnet_id      = azurerm_subnet.subnet2.id
  allocation_method   = "Static"
  enable_ssh_key      = true
  extra_ssh_keys      = ["monica_id_rsa.pub"]
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

  depends_on = [azurerm_resource_group.test]
}

module "debianservers2" {
  source                           = "../../"
  vm_hostname                      = "${random_id.ip_dns.hex}-d2"
  resource_group_name              = azurerm_resource_group.test.name
  location                         = var.location_alt
  admin_username                   = var.admin_username
  vm_os_simple                     = var.vm_os_simple_2
  vnet_subnet_id                   = azurerm_subnet.subnet2.id
  enable_ssh_key                   = true
  delete_data_disks_on_termination = true
  ssh_key                          = ""
  ssh_key_values                   = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8GIRF1Snlg9NKCmM74RHXqRGMXyui088+ntQqkQkFIL/BrlgP3CzOgHQmJ+3f0Up/+9UY9vX7AmT7WxVTyqBHT/Aes3VmU3wLO5/MMV/HRrT4z2QV/80futhxjk2unNdWGvbFcR6Y3I44EJFmr8GMbyXRtr0ibuv8BlTYx/K6AXSJ3V+kBqXMOF1QRvVoX9fJKPKjMsebe0cB1IYlm9KLqtciMy+aFOEsSNfrw5cNVsQfK3BgOUKAHsLfBiR7imA2ca+hh005GEtcVJvpvFzcM+bZggUpdqQwIzk1Kv/tROiJiGS0NnyzoxIZYeM3z/mQ5qnglp+174XGCG66EAnVdf5kbaI0Iu7FpAmVhJ92N+MNKoP6vT8cMkYYZf3RaiMMnzjswK/VLbb5ks6Qe9qEPXW1IBtkaaF7+0PCWbPr86I0G2bOa2tFyOHm046Z9sRlkaOO95hmer6Y6MUbMpfeprmjR87u6MVOPglnARfV3UI9i6wOUhVVIi6Wb424HWU="]

  depends_on = [azurerm_resource_group.test]
}

module "windowsservers" {
  source              = "../../"
  vm_hostname         = "${random_id.ip_dns.hex}-w" // line can be removed if only one VM module per resource group
  resource_group_name = azurerm_resource_group.test.name
  location            = var.location_alt
  is_windows_image    = true
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["winsimplevmips-${random_id.ip_dns.hex}"] // change to a unique name per datacenter region
  vnet_subnet_id      = azurerm_subnet.subnet3.id
  license_type        = var.license_type
  identity_type       = "UserAssigned"
  identity_ids        = [azurerm_user_assigned_identity.test.id]
  os_profile_secrets = [{
    source_vault_id   = azurerm_key_vault.test.id
    certificate_url   = azurerm_key_vault_certificate.test.secret_id
    certificate_store = "My"
  }]

  depends_on = [azurerm_resource_group.test]
}
