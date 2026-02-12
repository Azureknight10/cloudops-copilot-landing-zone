output "app_default_hostname" {
  value       = azurerm_linux_web_app.app.default_hostname
  description = "Default hostname of the app."
}
