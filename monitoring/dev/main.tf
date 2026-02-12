terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Use your dev/platform subscription for monitoring resources
  subscription_id = "a2300bf2-6091-4887-bba1-a371a34ce245"
}

# Monitoring resource group (or reuse an existing RG if you prefer)
resource "azurerm_resource_group" "monitoring" {
  name     = "rg-cloudops-monitoring-dev"
  location = "eastus"  # match your hub region
  tags = {
    env   = "dev"
    owner = "shane"
    app   = "cloudops-landing-zone"
  }
}

# Central Log Analytics workspace for hub + spokes
resource "azurerm_log_analytics_workspace" "platform" {
  name                = "log-cloudops-platform-dev"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name

  sku               = "PerGB2018"
  retention_in_days = 30  # adjust to 60/90 later if needed

  tags = {
    env   = "dev"
    owner = "shane"
    app   = "cloudops-landing-zone"
  }
}
