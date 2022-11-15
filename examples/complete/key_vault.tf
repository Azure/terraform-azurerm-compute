data "curl" "public_ip" {
  count = var.key_vault_firewall_bypass_ip_cidr == null ? 1 : 0

  http_method = "GET"
  uri         = "https://api.ipify.org?format=json"
}

locals {
  # We cannot use coalesce here because it's not short-circuit and public_ip's index will cause error
  public_ip = var.key_vault_firewall_bypass_ip_cidr == null ? jsondecode(data.curl.public_ip[0].response).ip : var.key_vault_firewall_bypass_ip_cidr
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  location                    = var.location_alt
  name                        = "test${random_id.ip_dns.hex}kv"
  resource_group_name         = azurerm_resource_group.test.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [local.public_ip]
  }
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  object_id    = coalesce(var.managed_identity_principal_id, data.azurerm_client_config.current.object_id)
  tenant_id    = data.azurerm_client_config.current.tenant_id
  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update",
  ]
  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]
  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]

  timeouts {
    delete = "45m"
    update = "45m"
  }
}

resource "azurerm_key_vault_access_policy" "test_vm" {
  key_vault_id = azurerm_key_vault.test.id
  object_id    = azurerm_user_assigned_identity.test.principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  certificate_permissions = [
    "Get",
  ]
  key_permissions = [
    "Get",
  ]
  secret_permissions = [
    "Get",
  ]

  timeouts {
    delete = "45m"
    update = "45m"
  }
}


resource "azurerm_key_vault_certificate" "test" {
  key_vault_id = azurerm_key_vault.test.id
  name         = "test${random_id.ip_dns.hex}kvcert"

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }
    key_properties {
      exportable = true
      key_type   = "RSA"
      reuse_key  = true
      key_size   = 2048
    }
    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = 30
      }
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    x509_certificate_properties {
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]
      subject            = "CN=hello-world"
      validity_in_months = 12
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      subject_alternative_names {
        dns_names = ["internal.contoso.com", "domain.hello.world"]
      }
    }
  }

  depends_on = [azurerm_key_vault_access_policy.test, azurerm_key_vault_access_policy.test_vm]
}
