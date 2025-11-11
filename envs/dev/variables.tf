#############################################
# VARIABLES (Dynamic Storage Accounts)
#############################################

variable "storage_accounts" {
  description = "Map of multiple storage accounts to create dynamically"
  type = map(object({
    storage_account_name = string
    location             = string
    account_tier         = string
    account_kind         = string
    replication_type     = string
    allowed_ips          = list(string)
    vnet_subnet_ids      = list(string)
    resource_access_rules = list(object({
      tenant_id   = string
      resource_id = string
    }))
    tags = map(string)
  }))
}
variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}
variable "resource_group_name" {
  description = "Resource group name for all storage accounts"
  type        = string
}


# Module deployment toggles
variable "deploy_storage" {
  description = "Set true to deploy the storage module"
  type        = bool
  default     = false
}