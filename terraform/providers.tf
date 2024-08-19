# Provide configuration details for Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.31.1"
    }
  }
}

# Provide config details for Azure Terraform provider
provider "azurerm" {
  features {}
}