variable "vm_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "availability_zone" {
  type    = string
  default = ""
}

variable "admin_username" {
  type    = string
  default = "vmadmin"
}

variable "admin_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "ssh_key_from_keyvault" {
  type    = bool
  default = false
}

variable "ssh_key_vault_name" {
  type    = string
  default = ""
}

variable "ssh_key_vault_rg" {
  type    = string
  default = ""
}

variable "ssh_public_key_secret_name" {
  type    = string
  default = ""
}

variable "ssh_public_key" {
  type    = string
  default = ""
}

variable "network" {
  description = "Network config for this VM. Pass subnet_id from root."
  type = object({
    subnet_id = string
  })
}

variable "create_nic" {
  type    = bool
  default = true
}

variable "network_interface_id" {
  type    = string
  default = ""
}

variable "private_ip_allocation" {
  type    = string
  default = "Dynamic"
}

variable "private_ip_address" {
  type    = string
  default = null
}

variable "attach_public_ip" {
  type    = bool
  default = false
}

variable "public_ip_allocation" {
  type    = string
  default = "Dynamic"
}

variable "public_ip_sku" {
  type    = string
  default = "Basic"
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "os_disk_name" {
  type    = string
  default = ""
}

variable "os_disk_size_gb" {
  type    = number
  default = 64
}

variable "os_disk_storage_account_type" {
  type    = string
  default = "Premium_LRS"
}

variable "os_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "create_os_disk_resource" {
  type    = bool
  default = false
}

variable "identity_type" {
  type    = string
  default = "SystemAssigned"
}

variable "boot_diagnostics_enabled" {
  type    = bool
  default = true
}

variable "boot_diagnostics_storage_account_uri" {
  type    = string
  default = ""
}

variable "data_disks" {
  type = list(object({
    name                 = string
    lun                  = number
    create_new           = bool
    existing_disk_id     = string
    disk_size_gb         = number
    storage_account_type = string
    caching              = string
  }))
  default = []
}

variable "extensions" {
  type = list(object({
    name                = string
    publisher           = string
    type                = string
    type_handler_version= string
    settings            = map(any)
    protected_settings  = map(any)
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "admin_password_secret_name" {
  description = "Optional Key Vault secret name for Windows admin password"
  type        = string
  default     = "adminPassword"
}
variable "encryption_at_host" {
  type    = bool
  default = true
}
variable "nsg" {
  description = "Optional NSG configuration"
  type = object({
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
  default = null
}