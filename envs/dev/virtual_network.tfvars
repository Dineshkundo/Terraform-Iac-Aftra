subscription_id = "d629b553-466f-4caa-b64b-9ba2bae97c3f"

############################################################
# DEPLOY ONLY VIRTUAL NETWORK
############################################################
deploy_vnet = true
deploy_vm   = false
deploy_kv   = false
deploy_storage = false

############################################################
# VIRTUAL NETWORK CONFIG
############################################################
virtual_networks = {
  dev = {
    vnet_name           = "Test-DevVnet"
    location            = "eastus"
    resource_group_name = "CODA_RG"
    address_space       = ["10.0.0.0/16"]

    ########################################################
    # SUBNETS
    ########################################################
    subnets = {

      GatewaySubnet = {
        name           = "GatewaySubnet"
        address_prefix = "10.0.6.0/24"

        nsg_id         = null
        route_table_id = null

        enforce_private_link_endpoint_network_policies = false
        enforce_private_link_service_network_policies  = false

        service_endpoints = [
          "Microsoft.KeyVault",
          "Microsoft.Storage"
        ]

        delegations = []
      }

      AzureFirewallManagementSubnet = {
        name           = "AzureFirewallManagementSubnet"
        address_prefix = "10.0.3.0/24"

        nsg_id         = null
        route_table_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/routeTables/03ad623a-f44b-4720-9322-7efd74e44eb8"

        enforce_private_link_endpoint_network_policies = false
        enforce_private_link_service_network_policies  = false

        service_endpoints = [
          "Microsoft.KeyVault",
          "Microsoft.Storage"
        ]

        delegations = []
      }

      Subnet1 = {
        name           = "Subnet1"
        address_prefix = "10.0.1.0/24"

        nsg_id         = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/networkSecurityGroups/NSGPublicSubnet"
        route_table_id = null

        enforce_private_link_endpoint_network_policies = false
        enforce_private_link_service_network_policies  = false

        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.KeyVault",
          "Microsoft.Sql"
        ]

        delegations = []
      }

      AzureFirewallSubnet = {
        name           = "AzureFirewallSubnet"
        address_prefix = "10.0.4.0/24"

        nsg_id         = null
        route_table_id = null

        enforce_private_link_endpoint_network_policies = false
        enforce_private_link_service_network_policies  = false

        service_endpoints = [
          "Microsoft.KeyVault",
          "Microsoft.Storage"
        ]

        delegations = []
      }

      subnet3 = {
        name           = "subnet3"
        address_prefix = "10.0.8.0/22"

        nsg_id         = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/networkSecurityGroups/NSGPrivateSubnet"
        route_table_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/routeTables/AKStoOnpremises"

        enforce_private_link_endpoint_network_policies = false
        enforce_private_link_service_network_policies  = false

        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.KeyVault",
          "Microsoft.Sql"
        ]

        delegations = []
      }

      Subnet2 = {
        name           = "Subnet2"
        address_prefix = "10.0.2.0/24"

        nsg_id         = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/networkSecurityGroups/NSGPrivateSubnet"
        route_table_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/routeTables/AKStoOnpremises"

        enforce_private_link_endpoint_network_policies = false
        enforce_private_link_service_network_policies  = false

        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.KeyVault"
        ]

        delegations = []
      }

      Subnet4 = {
        name           = "Subnet4"
        address_prefix = "10.0.20.0/24"

        nsg_id         = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/networkSecurityGroups/NSGPrivateSubnet"
        route_table_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/routeTables/AKStoOnpremises"

        enforce_private_link_endpoint_network_policies = false
        enforce_private_link_service_network_policies  = false

        service_endpoints = []

        delegations = [
          {
            name         = "dnsResolvers"
            service_name = "Microsoft.Network/dnsResolvers"
          }
        ]
      }
    }

    ########################################################
    # VNET PEERINGS
    ########################################################
    peerings = {
      governance = {
        name                    = "test-governance"
        remote_vnet_id          = "/subscriptions/24c24505-fc0c-44cc-8ae7-42ff678fc879/resourceGroups/Security-Governance-RG/providers/Microsoft.Network/virtualNetworks/Security-Governance-VNet"
        allow_vnet_access       = true
        allow_forwarded_traffic = true
        allow_gateway_transit   = true
        use_remote_gateways     = false
      }
    }

    ########################################################
    # TAGS
    ########################################################
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "CODA"
    }
  }
}
