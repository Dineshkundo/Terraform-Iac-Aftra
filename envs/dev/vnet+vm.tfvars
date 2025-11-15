subscription_id = "d629b553-466f-4caa-b64b-9ba2bae97c3f"

############################################################
# CREATE NEW VNET
############################################################
deploy_vnet = true

virtual_networks = {
  dev = {
    vnet_name           = "testVnet"
    location            = "eastus"
    resource_group_name = "CODA_RG"
    address_space       = ["10.10.0.0/16"]

    subnets = {
      Subnet1 = {
        name             = "Subnet1"
        address_prefix   = "10.10.1.0/24"
        nsg_id           = null
        route_table_id   = null
        service_endpoints = ["Microsoft.KeyVault"]
        delegations       = []
      }
    }

    peerings = {}
    tags = {
      Environment = "dev"
    }
  }
}

############################################################
# DEPLOY VMs
############################################################
deploy_vm = true

virtual_machines = {
  
  ##########################################################
  # VM 1 - USE EXISTING VNET
  ##########################################################
  existingvm = {
    vm_name             = "existing-vm"
    os_type             = "Linux"
    location            = "eastus"
    resource_group_name = "CODA_RG"
    vm_size             = "Standard_B2ms"
    availability_zone   = "1"

    admin_username = "azureuser"
    admin_password = ""

    ssh_key_from_keyvault      = true
    ssh_key_vault_name         = "CODADEV"
    ssh_key_vault_rg           = "CODA_RG"
    ssh_public_key_secret_name = "sshPublicKey"
    ssh_public_key             = ""

    network = {
      use_existing       = true
      existing_subnet_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/DevVnet/subnets/Subnet1"
      existing_vnet_id   = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/DevVnet"
      vnet_key           = ""
      subnet_name        = ""
    }

    create_nic           = true
    network_interface_id = ""
    attach_public_ip     = false

    image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }

    os_disk_name                 = "existing-vm-osdisk"
    os_disk_size_gb              = 30
    os_disk_storage_account_type = "Premium_LRS"

    data_disks = []

    extensions = []
    nsg = {
      create_nic_nsg = true
      rules = [{
        name                       = "AllowSSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "0.0.0.0/0"
        destination_address_prefix = "*"
      }]
    }

    tags = {
      service = "existing-service"
    }
  },

  ##########################################################
  # VM 2 - USE NEW CREATED VNET
  ##########################################################
  devvm = {
    vm_name             = "newvm"
    os_type             = "Linux"
    location            = "eastus"
    resource_group_name = "CODA_RG"
    vm_size             = "Standard_B2ms"
    availability_zone   = "1"

    admin_username = "azureuser"
    admin_password = ""

    ssh_key_from_keyvault      = false
    ssh_key_vault_name         = ""
    ssh_key_vault_rg           = ""
    ssh_public_key_secret_name = "sshPublicKey"
    ssh_public_key             = ""

    network = {
      use_existing       = false
      vnet_key           = "dev" //virtual_network dev{} name
      subnet_name        = "Subnet1"
      existing_subnet_id = ""
      existing_vnet_id   = ""
    }

    create_nic           = true
    network_interface_id = ""
    attach_public_ip     = false

    image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }

    os_disk_name                 = "newvm-osdisk"
    os_disk_size_gb              = 30
    os_disk_storage_account_type = "Premium_LRS"

    data_disks  = []
    extensions  = []
    nsg = {
      create_nic_nsg = false
      rules = []
    }

    tags = {
      service = "new-service"
    }
  }
}
