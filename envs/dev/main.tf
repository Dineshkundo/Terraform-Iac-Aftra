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

# Conditional module calls based on environment variables (via Jenkins)
#locals {
# deploy_storage = var.deploy_storage
#  deploy_compute = var.deploy_compute
#  deploy_sql     = var.deploy_sql
#}

#############################################
# DYNAMIC STORAGE ACCOUNT CREATION
#############################################
module "storage" {
  for_each = var.deploy_storage ? var.storage_accounts : {}
  source   = "../../modules/storage"

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