terraform {
  backend "azurerm" {
    resource_group_name  = "CODA_RG"
    storage_account_name = "codadevsa"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}