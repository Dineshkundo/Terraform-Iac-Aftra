terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.52"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
  use_msi                         = true
  subscription_id                 = "d629b553-466f-4caa-b64b-9ba2bae97c3f"
  resource_provider_registrations = "none"
}


#############################################
# DYNAMIC STORAGE ACCOUNT CREATION
#############################################
module "storage" {
  for_each = var.deploy_storage ? var.storage_accounts : {}
  source   = "./modules/storage"

  storage_account_name  = each.value.storage_account_name
  resource_group_name   = var.resource_group_name
  location              = each.value.location
  account_tier          = each.value.account_tier
  account_kind          = each.value.account_kind
  replication_type      = each.value.replication_type
  allowed_ips           = each.value.allowed_ips
  vnet_subnet_ids       = each.value.vnet_subnet_ids
  resource_access_rules = each.value.resource_access_rules
  tags                  = each.value.tags
}

##################################################
# KEY VAULT
#####################
module "keyvault" {
  for_each = var.deploy_kv ? var.keyvaults : {}
  source   = "./modules/keyvault"

  keyvaults = {
    for k, v in var.keyvaults : k => v
  }
}
#######################################
# VM
#########################################
locals {
  vms = var.virtual_machines
}

#############################################
# DYNAMIC VM CREATION MODULE
#############################################
module "virtual_machine" {
  source   = "./modules/virtual_machine"
  for_each = var.deploy_vm ? local.vms : {}

  vm_name                    = each.value.vm_name
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  os_type                    = each.value.os_type
  vm_size                    = lookup(each.value, "vm_size", "Standard_D2s_v3")
  availability_zone          = lookup(each.value, "availability_zone", "")
  admin_username             = lookup(each.value, "admin_username", "vmadmin")
  admin_password             = lookup(each.value, "admin_password", "")
  ssh_key_from_keyvault      = lookup(each.value, "ssh_key_from_keyvault", false)
  ssh_key_vault_name         = lookup(each.value, "ssh_key_vault_name", "")
  ssh_key_vault_rg           = lookup(each.value, "ssh_key_vault_rg", "")
  ssh_public_key_secret_name = lookup(each.value, "ssh_public_key_secret_name", "")
  ssh_public_key             = lookup(each.value, "ssh_public_key", "")
  admin_password_secret_name = lookup(each.value, "admin_password_secret_name", "")
  network                    = lookup(each.value, "network", {})
  create_nic                 = lookup(each.value, "create_nic", true)
  network_interface_id       = lookup(each.value, "network_interface_id", "")
  attach_public_ip           = lookup(each.value, "attach_public_ip", false)
  nsg = lookup(each.value, "nsg", null)
  image = lookup(each.value, "image", null) != null ? each.value.image : {
    publisher = each.value.os_type == "Windows" ? "MicrosoftWindowsServer" : "Canonical"
    offer     = each.value.os_type == "Windows" ? "WindowsServer" : "0001-com-ubuntu-server-jammy"
    sku       = each.value.os_type == "Windows" ? "2019-datacenter-gensecond" : "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk_name                 = lookup(each.value, "os_disk_name", "${each.value.vm_name}-osdisk")
  os_disk_size_gb              = lookup(each.value, "os_disk_size_gb", 64)
  os_disk_storage_account_type = lookup(each.value, "os_disk_storage_account_type", "Premium_LRS")
  data_disks                   = lookup(each.value, "data_disks", [])
  extensions                   = lookup(each.value, "extensions", [])
  tags                         = lookup(each.value, "tags", { Environment = "dev", ManagedBy = "Terraform" })
}