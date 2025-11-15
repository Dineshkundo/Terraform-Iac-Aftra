output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "Map of subnet name => subnet ID"
  value = {
    for name, subnet in azurerm_subnet.subnets :
    name => subnet.id
  }
}

output "peering_ids" {
  description = "Map of peering name => peering ID"
  value = {
    for k, v in azurerm_virtual_network_peering.peerings : k => v.id
  }
}
