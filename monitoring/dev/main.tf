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

  subscription_id = "a2300bf2-6091-4887-bba1-a371a34ce245"
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-cloudops-monitoring-dev"
  location = "eastus"
  tags = {
    env   = "dev"
    owner = "shane"
    app   = "cloudops-landing-zone"
  }
}

resource "azurerm_log_analytics_workspace" "platform" {
  name                = "log-cloudops-platform-dev"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = {
    env   = "dev"
    owner = "shane"
    app   = "cloudops-landing-zone"
  }
}

resource "azurerm_monitor_diagnostic_setting" "dev_spoke_app_to_log" {
  name                       = "ds-dev-spoke-app-to-log-platform-dev"
  target_resource_id         = "/subscriptions/a2300bf2-6091-4887-bba1-a371a34ce245/resourceGroups/rg-cloudops-hubspoke/providers/Microsoft.Web/sites/dev-spoke-app"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id

  enabled_log {
    category = "AppServiceHTTPLogs"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "AppServiceConsoleLogs"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "AppServiceAppLogs"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}
