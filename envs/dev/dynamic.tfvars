deploy_storage      = true
resource_group_name = "CODA_RG"

storage_accounts = {
  dev = {
    storage_account_name = "codadevsa"
    location             = "eastus"
    account_tier         = "Standard"
    account_kind         = "StorageV2"
    replication_type     = "LRS"
    allowed_ips          = ["38.79.64.66"]
    vnet_subnet_ids      = ["/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/ProdVnet/subnets/Subnet1"]
    resource_access_rules = [
      {
        tenant_id   = "2eb52881-f5b4-4855-9142-cd907aa33267"
        resource_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.DataFactory/factories/CODADevDF"
      }
    ]
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "CODA"
    }
  }

  uat = {
    storage_account_name  = "codauatsa"
    location              = "eastus2"
    account_tier          = "Standard"
    account_kind          = "StorageV2"
    replication_type      = "ZRS"
    allowed_ips           = ["52.101.66.11"]
    vnet_subnet_ids       = ["/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/UatVnet/subnets/Subnet1"]
    resource_access_rules = []
    tags = {
      Environment = "uat"
      ManagedBy   = "Terraform"
      Project     = "CODA"
    }
  }

  prod = {
    storage_account_name = "codaprodsa"
    location             = "centralus"
    account_tier         = "Standard"
    account_kind         = "StorageV2"
    replication_type     = "GRS"
    allowed_ips          = ["40.33.22.8"]
    vnet_subnet_ids      = ["/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/ProdVnet/subnets/Subnet2"]
    resource_access_rules = [
      {
        tenant_id   = "2eb52881-f5b4-4855-9142-cd907aa33267"
        resource_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.DataFactory/factories/CODAProdDF"
      }
    ]
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
      Project     = "CODA"
    }
  }
}