terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Partial backend config. Values are supplied at init time:
  #   terraform init -backend-config="resource_group_name=..." \
  #                  -backend-config="storage_account_name=..." \
  #                  -backend-config="container_name=tfstate" \
  #                  -backend-config="key=aks-platform-dev.tfstate"
  # Auth uses Azure AD (no storage keys): set ARM_USE_AZUREAD=true.
  backend "azurerm" {}
}

# azurerm 4.x requires a subscription ID. Provide it with the
# ARM_SUBSCRIPTION_ID environment variable (the pipeline does this for you).
provider "azurerm" {
  features {}
}
