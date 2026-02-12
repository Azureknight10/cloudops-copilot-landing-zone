variable "resource_group_name" {
  type        = string
  description = "Resource group for the app."
}

variable "location" {
  type        = string
  description = "Azure region for the app."
  default     = "centralus"
}

variable "app_identity_id" {
  type        = string
  description = "User-assigned managed identity resource ID."
}

variable "app_identity_client_id" {
  type        = string
  description = "User-assigned managed identity client ID."
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name for app secrets."
}

resource "azurerm_service_plan" "app_plan" {
  name                = "dev-spoke-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  # was: sku_name = "P0v3"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "dev-spoke-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan.id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.app_identity_id]
  }

  site_config {
    always_on = false
  }

  app_settings = {
    "KEY_VAULT_NAME"          = var.key_vault_name
    "AZURE_CLIENT_ID"         = var.app_identity_client_id
    "ASPNETCORE_ENVIRONMENT"  = "Development"
  }
}
