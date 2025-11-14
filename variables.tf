variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default     = "dev" # ✅ prevents prompts
}
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
}

variable "location" {
  description = "Default Azure region"
  type        = string
  default     = "eastus"
}

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
  default = {} # ✅ prevents prompt when deploy_storage = false
}
variable "resource_group_name" {
  description = "Resource group name for all storage accounts"
  type        = string
  default     = "" # ✅ prevents prompt when not used
}


# Module deployment toggles
variable "deploy_storage" {
  description = "Set true to deploy the storage module"
  type        = bool
  default     = false
}
################################################
# KEY VAULT
################################################
variable "deploy_kv" {
  description = "Set true to deploy the Key Vault module"
  type        = bool
  default     = false
}
variable "keyvaults" {
  description = "Map of Key Vault configurations"
  type = map(object({
    name                = string
    location            = string
    tenant_id           = string
    sku_name            = string
    resource_group_name = string
    ip_rules            = list(string)
    vnet_subnet_ids     = list(string)
    access_policies = list(object({
      tenant_id               = string
      object_id               = string
      key_permissions         = list(string)
      secret_permissions      = list(string)
      certificate_permissions = list(string)
    }))
    secrets = list(string)
    keys    = list(string)
    tags    = map(string)
  }))
  default = {}
}
#######################################################################
# VM
#######################################################################
variable "deploy_vm" {
  type        = bool
  description = "Whether to deploy VMs"
  default     = false
}
variable "virtual_machines" {
  description = "Map of VMs to create"
  type = map(object({
    location            = string
    resource_group_name = string
    vm_name             = string
    os_type             = string
    vm_size             = string
    availability_zone   = string

    admin_username      =string
    admin_password      = optional(string, "")

    # SSH / Key Vault
    ssh_key_from_keyvault      = bool
    ssh_key_vault_name         = string
    ssh_key_vault_rg           = string
    ssh_public_key_secret_name = string
    ssh_public_key             = string
    admin_password_secret_name = optional(string, "adminPassword")

    # Network configuration
    network = object({
      use_existing        = bool
      existing_vnet_id    = string
      existing_subnet_id  = string
      vnet_name           = string
      address_space       = list(string)
      subnet_name         = string
      subnet_prefixes     = list(string)
      service_endpoints   = list(string)
    })

    create_nic           = bool
    network_interface_id = optional(string, "")
    attach_public_ip     = bool

    # Image details
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })

    # OS Disk
    os_disk_name                 = string
    os_disk_size_gb              = number
    os_disk_storage_account_type = string

    # Data Disk list
    data_disks = list(object({
      name                 = string
      lun                  = number
      create_new           = bool
      existing_disk_id     = string
      disk_size_gb         = number
      storage_account_type = string
      caching              = string
    }))

    # Extensions
    extensions = list(object({
      name                 = string
      publisher            = string
      type                 = string
      type_handler_version = string
      settings             = map(any)
      protected_settings   = map(any)
    }))

    # � NSG Block (Fixes your issue)
    nsg = object({
      create_nic_nsg = bool
      rules = list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      }))
    })

    tags = map(string)
  }))
  default = {}
}