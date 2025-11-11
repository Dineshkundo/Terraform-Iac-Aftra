variable "storage_account_name" {
  type        = string
  description = "Storage account name"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "account_tier" {
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
}

variable "https_traffic_only_enabled" {
  type    = bool
  default = true
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = false
}

variable "shared_access_key_enabled" {
  type    = bool
  default = true
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "large_file_share_enabled" {
  type    = bool
  default = true
}

variable "bypass_services" {
  type    = list(string)
  default = ["Logging", "Metrics", "AzureServices"]
}

variable "default_network_action" {
  type    = string
  default = "Deny"
}

variable "allowed_ips" {
  type    = list(string)
  default = []
}

variable "vnet_subnet_ids" {
  type    = list(string)
  default = []
}

variable "publish_internet_endpoints" {
  type    = bool
  default = false
}

variable "publish_microsoft_endpoints" {
  type    = bool
  default = false
}

variable "routing_choice" {
  type    = string
  default = "MicrosoftRouting"
}

variable "blob_delete_retention_enabled" {
  type    = bool
  default = true
}

variable "blob_delete_retention_days" {
  type    = number
  default = 7
}

variable "container_delete_retention_enabled" {
  type    = bool
  default = true
}

variable "container_delete_retention_days" {
  type    = number
  default = 7
}

variable "file_share_delete_retention_days" {
  type    = number
  default = 14
}

variable "file_share_quota" {
  type    = number
  default = 5120
}

variable "blob_containers" {
  type    = list(string)
  default = ["tfstate"]
}

variable "file_shares" {
  type    = list(string)
  default = ["fileshare1"]
}

variable "encryption_scope_name" {
  type    = string
  default = "default"
}

variable "enable_storage_lock" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
variable "resource_access_rules" {
  description = "List of resource access rules (tenant_id + resource_id) to grant access to this storage account"
  type = list(object({
    tenant_id   = string
    resource_id = string
  }))
  default = []
}
variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage, and StorageV2 accounts. Valid options are Hot, Cool, or Premium."
  type        = string
  default     = "Hot"
}

variable "versioning_enabled" {
  description = "Enable blob versioning in the storage account"
  type        = bool
  default     = false
}

variable "change_feed_enabled" {
  description = "Enable blob change feed for tracking blob-level changes"
  type        = bool
  default     = false
}