output "vm_id" {
  value = coalesce(
    try(azurerm_linux_virtual_machine.linux[0].id, null),
    try(azurerm_windows_virtual_machine.windows[0].id, null)
  )
}

output "private_ip" {
  value = (
    var.create_nic
    ? try(azurerm_network_interface.nic[0].private_ip_address, null)
    : null
  )
}

output "public_ip" {
  value = (
    var.attach_public_ip
    ? try(azurerm_public_ip.pip[0].ip_address, null)
    : null
  )
}