#######################################################
# DEPLOY FLAGS
#######################################################
deploy_vnet    = true
deploy_vm      = true
deploy_storage = false
deploy_kv      = false


#######################################################
# VIRTUAL NETWORKS
#######################################################
virtual_networks = {
  dev = {
    vnet_name           = "testVnet"
    location            = "eastus"
    resource_group_name = "CODA_RG"

    address_space = [
      "10.0.0.0/16"
    ]

    # --------------------------
    # Subnets (from Bicep)
    # --------------------------
    subnets = {
      GatewaySubnet = {
        name           = "GatewaySubnet"
        address_prefix = "10.0.6.0/24"

        nsg_id         = null
        route_table_id = null

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

        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.KeyVault"
        ]

        delegations = []
      }

      subnet3 = {
        name           = "subnet3"
        address_prefix = "10.0.8.0/22"

        nsg_id         = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/networkSecurityGroups/NSGPrivateSubnet"
        route_table_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/routeTables/AKStoOnpremises"

        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.KeyVault",
          "Microsoft.Sql"
        ]

        delegations = []
      }

      Subnet4 = {
        name           = "Subnet4"
        address_prefix = "10.0.20.0/24"

        nsg_id         = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/networkSecurityGroups/NSGPrivateSubnet"
        route_table_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/routeTables/AKStoOnpremises"

        service_endpoints = []
        
        delegations = [
          {
            name         = "dnsResolvers"
            service_name = "Microsoft.Network/dnsResolvers"
          }
        ]
      }

      AzureFirewallSubnet = {
        name           = "AzureFirewallSubnet"
        address_prefix = "10.0.4.0/24"

        nsg_id         = null
        route_table_id = null

        service_endpoints = [
          "Microsoft.KeyVault",
          "Microsoft.Storage"
        ]

        delegations = []
      }
    }

    # --------------------------
    # Peering (from Bicep)
    # --------------------------
    peerings = {
      governance = {
        name                 = "CODA-SECURITY-GOVERNANCE-LINK"
        remote_vnet_id       = "/subscriptions/24c24505-fc0c-44cc-8ae7-42ff678fc879/resourceGroups/Security-Governance-RG/providers/Microsoft.Network/virtualNetworks/Security-Governance-VNet"
        allow_vnet_access    = true
        allow_forwarded_traffic = true
        allow_gateway_transit = true
        use_remote_gateways   = false
      }
    }

    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "CODA"
    }
  }
}


#######################################################
# VIRTUAL MACHINES
#######################################################
virtual_machines = {
  devvm = {
    vm_name             = "tf-devvm"
    resource_group_name = "CODA_RG"
    location            = "eastus"
    os_type             = "Linux"
    vm_size             = "Standard_B2ms"

    admin_username = "devadmin"
    admin_password = ""

    ssh_key_from_keyvault      = true
    ssh_key_vault_name         = "CODADEV"
    ssh_key_vault_rg           = "CODA_RG"
    ssh_public_key_secret_name = "sshPublicKey"
    ssh_public_key             = ""

    create_nic           = true
    network_interface_id = ""
    attach_public_ip     = false

    # --------------------------
    # VM will attach to this subnet dynamically
    # --------------------------
    network = {
      vnet_key    = "dev"
      subnet_name = "Subnet1"
    }

    os_disk_name                 = "tf-devvm-osdisk"
    os_disk_size_gb              = 30
    os_disk_storage_account_type = "Premium_LRS"

    data_disks = []

    image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }

    extensions = []

    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
