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

module "security" {
  source = "../security"

  resource_group_name = "rg-cloudops-hubspoke"
  tenant_id           = "f5256f78-5cf4-4ede-aa3c-31fb2a3c78fb"
}

output "dev_key_vault_name" {
  description = "Key Vault name for the dev network environment."
  value       = module.security.key_vault_name
}

output "dev_app_identity_id" {
  description = "UAMI resource ID for the dev network environment."
  value       = module.security.app_identity_id
}

output "dev_app_identity_client_id" {
  description = "UAMI client ID for the dev network environment."
  value       = module.security.app_identity_client_id
}
module "spoke_app" {
  source = "../../../app/spoke"

  resource_group_name      = "rg-cloudops-hubspoke"
  app_identity_id          = module.security.app_identity_id
  app_identity_client_id   = module.security.app_identity_client_id
  key_vault_name           = module.security.key_vault_name
}

output "dev_app_hostname" {
  value       = module.spoke_app.app_default_hostname
  description = "Dev app default hostname."
}
