variable "key_vaults" {
  description = "Map of Key Vault configurations"
  type = map(object({
    name                 = string
    location             = string
    tenant_id            = string
    sku_name             = string
    resource_group_name  = string
    ip_rules             = list(string)
    vnet_subnet_ids      = list(string)
    access_policies = list(object({
      tenant_id = string
      object_id = string
      key_permissions = list(string)
      secret_permissions = list(string)
      certificate_permissions = list(string)
    }))
    secrets = list(string)
    keys    = list(string)
    tags    = map(string)
  }))
}