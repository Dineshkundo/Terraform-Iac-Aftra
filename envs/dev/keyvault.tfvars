deploy_kv = true

keyvaults = {
  testkv = {
    name                = "test-kv-dev01"
    location            = "eastus"
    resource_group_name = "CODA_RG"

    tenant_id = "d629b553-466f-4caa-b64b-9ba2bae97c3f" # <-- use your correct tenant

    sku_name = "standard"

    # ----------------------
    # NETWORK RULES
    # ----------------------
    ip_rules = [
      "10.0.0.4",
      "52.168.20.10"
    ]

    # must be a LIST of subnet IDs
    vnet_subnet_ids = [
      "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/Test-DevVnet/subnets/Subnet1"
    ]

    # ----------------------
    # ACCESS POLICIES
    # ----------------------
    access_policies = [
      {
        tenant_id               = "d629b553-466f-4caa-b64b-9ba2bae97c3f"
        object_id               = "11111111-2222-3333-4444-555555555555" # user / SPN / managed identity

        key_permissions = [
          "Get",
          "List",
          "Create",
          "Delete"
        ]

        secret_permissions = [
          "Get",
          "List",
          "Set",
          "Delete"
        ]

        certificate_permissions = [
          "Get",
          "List",
          "Create",
          "Delete"
        ]
      }
    ]

    # ----------------------
    # OPTIONAL SECRETS
    # ----------------------
    secrets = [
      "appSecret",
      "dbPassword"
    ]

    # ----------------------
    # OPTIONAL KEYS
    # ----------------------
    keys = [
      "appKey1",
      "signingKey"
    ]

    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "CODA"
    }
  }
}
