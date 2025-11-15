output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = {
    for k, v in azurerm_subnet.subnets : k => v.id
  }
}

output "peering_ids" {
  value = {
    for k, v in azurerm_virtual_network_peering.peerings : k => v.id
  }
}
