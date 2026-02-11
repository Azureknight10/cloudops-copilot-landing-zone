resource "azurerm_resource_group" "network" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.project_tags
}

# HUB VNET
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.project_tags
}

resource "azurerm_subnet" "hub_default" {
  name                 = "subnet-hub-default"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "hub_nsg" {
  name                = "nsg-hub-default"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.project_tags
}

resource "azurerm_subnet_network_security_group_association" "hub_default_assoc" {
  subnet_id                 = azurerm_subnet.hub_default.id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id
}

# SPOKE VNET
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-app-dev"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.project_tags
}

resource "azurerm_subnet" "spoke_app" {
  name                 = "subnet-spoke-app"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "spoke_nsg" {
  name                = "nsg-spoke-app"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.project_tags
}

resource "azurerm_subnet_network_security_group_association" "spoke_app_assoc" {
  subnet_id                 = azurerm_subnet.spoke_app.id
  network_security_group_id = azurerm_network_security_group.spoke_nsg.id
}

# VNET PEERING HUB <-> SPOKE

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Useful outputs
output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke.id
}

output "hub_subnet_id" {
  value = azurerm_subnet.hub_default.id
}

output "spoke_app_subnet_id" {
  value = azurerm_subnet.spoke_app.id
}
