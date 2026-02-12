# security_outputs.tf
output "key_vault_id" {
  value       = azurerm_key_vault.main.id
  description = "Key Vault resource ID."
}

output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "Key Vault name."
}

output "app_identity_client_id" {
  value       = azurerm_user_assigned_identity.app_identity.client_id
  description = "Client ID of the user-assigned managed identity."
}

output "app_identity_principal_id" {
  value       = azurerm_user_assigned_identity.app_identity.principal_id
  description = "Principal (object) ID of the user-assigned managed identity."
}

output "app_identity_id" {
  value       = azurerm_user_assigned_identity.app_identity.id
  description = "Resource ID of the user-assigned managed identity."
}