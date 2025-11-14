resource "azurerm_key_vault" "this" {
  for_each            = var.keyvaults
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tenant_id           = each.value.tenant_id

  sku_name = each.value.sku_name

  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  rbac_authorization_enabled  = true
  enabled_for_deployment     = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = each.value.ip_rules
    virtual_network_subnet_ids = each.value.vnet_subnet_ids
  }

  dynamic "access_policy" {
    for_each = each.value.access_policies
    content {
      tenant_id               = access_policy.value.tenant_id
      object_id               = access_policy.value.object_id
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
    }
  }

  tags = each.value.tags
}

# -----------------------------
# -----------------------------
# -----------------------------
# Optional Secrets (Dynamic)
# -----------------------------
locals {
  # Build a flattened list of all secrets across all vaults
  all_secrets = flatten([
    for vault_key, vault in var.keyvaults : [
      for secret_name in vault.secrets : {
        vault_name = vault_key
        name       = secret_name
      }
    ]
  ])
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = {
    for s in local.all_secrets : "${s.vault_name}-${s.name}" => s
  }

  name         = each.value.name
  value        = "placeholder-value" # replace later with sensitive lookup or file()
  key_vault_id = azurerm_key_vault.this[each.value.vault_name].id
}

# -----------------------------
# -----------------------------
# Optional Keys (Dynamic)
# -----------------------------
locals {
  all_keys = flatten([
    for vault_key, vault in var.keyvaults : [
      for key_name in vault.keys : {
        vault_name = vault_key
        name       = key_name
      }
    ]
  ])
}

resource "azurerm_key_vault_key" "keys" {
  for_each = {
    for k in local.all_keys : "${k.vault_name}-${k.name}" => k
  }

  name         = each.value.name
  key_vault_id = azurerm_key_vault.this[each.value.vault_name].id
  key_type     = "RSA"
  key_size     = 2048
  # Required field
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "verify",
    "wrapKey",
    "unwrapKey"
  ]
}