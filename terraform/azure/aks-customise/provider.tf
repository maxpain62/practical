terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.50"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_provider_registration" "example" {
  name = "Microsoft.ContainerService"

  feature {
    name       = "AKS-DataPlaneAutoApprove"
    registered = true
  }
}