variable "location" {
  type        = string
  description = "Azure region for hub and spoke."
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for hub-spoke network."
  default     = "rg-cloudops-hubspoke"
}

variable "project_tags" {
  type        = map(string)
  description = "Common tags."
  default = {
    project = "cloudops-copilot-landing-zone"
    env     = "dev"
    owner   = "shane"
  }
}
