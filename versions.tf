terraform {
  required_version = "~>1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.8"
    }

    local = {
      source  = "hashicorp/local"
      version = "~>2.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}
