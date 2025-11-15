############################################################
# VIRTUAL NETWORK
############################################################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.tags
}

############################################################
# SUBNETS
############################################################
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  # Service Endpoints
  service_endpoints = each.value.service_endpoints

  # CORRECT attributes for AzureRM provider v4.52+
  enforce_private_link_endpoint_network_policies = try(each.value.enforce_private_link_endpoint_network_policies, false)
  enforce_private_link_service_network_policies  = try(each.value.enforce_private_link_service_network_policies, false)

  # Subnet Delegation (dynamic block)
  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_name
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

############################################################
# NSG ASSOCIATION
############################################################
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = {
    for key, subnet in var.subnets : key => subnet
    if subnet.nsg_id != null
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = each.value.nsg_id
}

############################################################
# ROUTE TABLE ASSOCIATION
############################################################
resource "azurerm_subnet_route_table_association" "route_assoc" {
  for_each = {
    for key, subnet in var.subnets : key => subnet
    if subnet.route_table_id != null
  }

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = each.value.route_table_id
}

############################################################
# VNET PEERING
############################################################
resource "azurerm_virtual_network_peering" "peerings" {
  for_each = var.peerings

  name                         = each.value.name
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = each.value.remote_vnet_id

  allow_virtual_network_access = each.value.allow_vnet_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}
