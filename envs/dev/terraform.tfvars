#############################################
# ENVIRONMENT SETTINGS
#############################################
env                 = "dev"
deploy_storage      = true
resource_group_name = "CODA_RG"

#############################################
# SINGLE STORAGE ACCOUNT (Dynamic Map)
#############################################
storage_accounts = {
  dev = {
    storage_account_name = "codadevsa"
    location             = "eastus"
    account_tier         = "Standard"
    account_kind         = "StorageV2"
    replication_type     = "LRS"
    allowed_ips          = ["38.79.64.66"]
    vnet_subnet_ids = [
      "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/ProdVnet/subnets/Subnet1"
    ]
    resource_access_rules = [
      {
        tenant_id   = "2eb52881-f5b4-4855-9142-cd907aa33267"
        resource_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.DataFactory/factories/CODAProdDF"
      }
    ]
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "CODA"
    }
  }
}
