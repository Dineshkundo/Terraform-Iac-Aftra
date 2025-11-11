#############################################
# STORAGE ACCOUNT (valid for azurerm 4.52.0)
#############################################
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = var.account_kind

  https_traffic_only_enabled      = var.https_traffic_only_enabled
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  min_tls_version                 = var.min_tls_version
  public_network_access_enabled   = var.public_network_access_enabled
  large_file_share_enabled        = var.large_file_share_enabled

  # Optional access tier
  access_tier = var.access_tier

  network_rules {
    default_action             = var.default_network_action
    bypass                     = var.bypass_services
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids  = var.vnet_subnet_ids
  }

  routing {
    publish_internet_endpoints  = var.publish_internet_endpoints
    publish_microsoft_endpoints = var.publish_microsoft_endpoints
    choice                      = var.routing_choice
  }

  # ✅ Correct way to configure blob & file properties now
  blob_properties {
    delete_retention_policy {
      days    = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days    = var.container_delete_retention_days
    }

    versioning_enabled  = var.versioning_enabled
    change_feed_enabled = var.change_feed_enabled
  }

  share_properties {
    retention_policy {
      days = var.file_share_delete_retention_days
    }

    smb {
      versions                        = ["SMB3.0", "SMB3.1.1"]
      authentication_types            = ["Kerberos"]
      channel_encryption_type         = ["AES-256-GCM"]
      kerberos_ticket_encryption_type = ["AES-256"]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

#############################################
# STORAGE CONTAINERS
#############################################
resource "azurerm_storage_container" "containers" {
  for_each = toset(var.blob_containers)

  name                  = each.key
  storage_account_id  = azurerm_storage_account.this.id
  container_access_type = "private"
}

#############################################
# STORAGE FILE SHARES
#############################################
resource "azurerm_storage_share" "shares" {
  for_each             = toset(var.file_shares)
  name                 = each.key
  storage_account_id = azurerm_storage_account.this.id
  quota                = var.file_share_quota
}

#############################################
# OPTIONAL ENCRYPTION SCOPE (no 'state' arg)
#############################################
resource "azurerm_storage_encryption_scope" "default" {
  name               = var.encryption_scope_name
  storage_account_id = azurerm_storage_account.this.id
  source             = "Microsoft.Storage"
}

#############################################
# OPTIONAL LOCK
#############################################
resource "azurerm_management_lock" "storage_lock" {
  count      = var.enable_storage_lock ? 1 : 0
  name       = "${var.storage_account_name}-lock"
  scope      = azurerm_storage_account.this.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion"
}

