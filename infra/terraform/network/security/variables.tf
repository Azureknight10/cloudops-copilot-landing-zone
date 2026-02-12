variable "resource_group_name" {
  type        = string
  description = "Existing resource group for security resources."
}

variable "tenant_id" {
  type        = string
  description = "AAD tenant ID for Key Vault."
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming Key Vault and identities."
  default     = "cloudops-hubspoke"
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default = {
    environment = "lab"
    owner       = "shane"
  }
}
