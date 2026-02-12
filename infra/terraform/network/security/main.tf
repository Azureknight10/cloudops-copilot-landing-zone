terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "a2300bf2-6091-4887-bba1-a371a34ce245"
  tenant_id       = "f5256f78-5cf4-4ede-aa3c-31fb2a3c78fb"
}


# Import the existing resource group (or mirror your network module’s RG definition)
data "azurerm_resource_group" "hubspoke" {
  name = var.resource_group_name
}

# User-assigned managed identity (UAMI)
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "${var.name_prefix}-uami-app"
  resource_group_name = data.azurerm_resource_group.hubspoke.name
  location            = data.azurerm_resource_group.hubspoke.location
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                       = "${var.name_prefix}-kv"
  location                   = data.azurerm_resource_group.hubspoke.location
  resource_group_name        = data.azurerm_resource_group.hubspoke.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  # Recommended: deny by default, allow only via access policies/RBAC
  public_network_access_enabled = false

  tags = var.tags
}

# Give the UAMI access to read secrets in the Key Vault
resource "azurerm_key_vault_access_policy" "uami_secrets" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.app_identity.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}
