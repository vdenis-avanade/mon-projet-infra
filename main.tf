terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate1754328" # Put YOUR unique numbers here!
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  # Pinning the subscription ensures Terraform always deploys to your VS Pro environment
  subscription_id = "7e1ed96d-b92f-4f11-bdcd-2b4f4f1f6ac4" 
}