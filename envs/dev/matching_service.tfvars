deploy_vm = true


virtual_machines = {
  matching_service = {
    location            = "eastus"
    resource_group_name = "CODA_RG"
    vm_name             = "tf-vm"
    os_type             = "Linux"
    vm_size             = "Standard_B2ms"
    availability_zone   = "1"

    admin_username = "matching-admin"
    admin_password = ""

    ssh_key_from_keyvault      = true
    ssh_key_vault_name         = "CODADEV"
    ssh_key_vault_rg           = "CODA_RG"
    ssh_public_key_secret_name = "sshPublicKey"
    ssh_public_key             = ""

    create_nic           = true
    network_interface_id = ""
    attach_public_ip     = false

    network = {
      use_existing       = true
      existing_vnet_id   = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/DevVnet"
      existing_subnet_id = "/subscriptions/d629b553-466f-4caa-b64b-9ba2bae97c3f/resourceGroups/CODA_RG/providers/Microsoft.Network/virtualNetworks/DevVnet/subnets/Subnet1"

      vnet_name          = ""
      address_space      = []
      subnet_name        = ""
      subnet_prefixes    = []
      service_endpoints  = []
    }

    os_disk_name                 = "tf-vm-osdisk"
    os_disk_size_gb              = 30
    os_disk_storage_account_type = "Premium_LRS"

    data_disks = []

    image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }

    extensions = [
      {
        name                 = "enablevmAccess"
        publisher            = "Microsoft.OSTCExtensions"
        type                 = "VMAccessForLinux"
        type_handler_version = "1.5"
        settings             = {}

        protected_settings = {
          username    = "matching-admin"
          password    = ""
          ssh_key     = ""
          reset_ssh   = ""
          remove_user = ""
          expiration  = ""
        }
      }
    ]
    nsg = {
      create_nic_nsg = true
      rules = [
        {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "38.79.64.66/32"
          destination_address_prefix = "*"
        }
      ]
    }
    tags = {
      service = "matching-engine"
    }
  }
}