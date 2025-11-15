#############################################
# Fetch Key Vault (optional)
#############################################
data "azurerm_key_vault" "kv" {
  count = (
    var.ssh_key_from_keyvault ||
    (var.os_type == "Windows" && var.admin_password == "")
  ) && var.ssh_key_vault_name != "" && var.ssh_key_vault_rg != "" ? 1 : 0

  name                = var.ssh_key_vault_name
  resource_group_name = var.ssh_key_vault_rg
}

#############################################
# Fetch SSH Public Key (optional)
#############################################
data "azurerm_key_vault_secret" "ssh_pub" {
  count        = var.ssh_key_from_keyvault && length(data.azurerm_key_vault.kv) > 0 ? 1 : 0
  name         = var.ssh_public_key_secret_name
  key_vault_id = data.azurerm_key_vault.kv[0].id
}

#############################################
# Fetch Windows Admin Password (optional)
#############################################
data "azurerm_key_vault_secret" "admin_password" {
  count = (
    var.os_type == "Windows" &&
    var.admin_password == "" &&
    length(data.azurerm_key_vault.kv) > 0
  ) ? 1 : 0

  name         = var.admin_password_secret_name
  key_vault_id = data.azurerm_key_vault.kv[0].id
}

locals {
  ssh_pub_key = (
    (var.ssh_key_from_keyvault && length(data.azurerm_key_vault_secret.ssh_pub) > 0)
      ? data.azurerm_key_vault_secret.ssh_pub[0].value
      : var.ssh_public_key
  )
}

#############################################
# Optional Public IP
#############################################
resource "azurerm_public_ip" "pip" {
  count               = var.attach_public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation
  sku                 = var.public_ip_sku
  tags                = var.tags
}

#############################################
# NIC (cleaned — uses only subnet_id)
#############################################
resource "azurerm_network_interface" "nic" {
  count               = var.create_nic ? 1 : 0
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.network.subnet_id
    private_ip_address_allocation = var.private_ip_allocation
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.attach_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

#############################################
# Network Security Group (Optional)
#############################################
resource "azurerm_network_security_group" "nsg" {
  count = (
    var.nsg != null && try(var.nsg.create_nic_nsg, false)
  ) ? 1 : 0

  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "nsg_rules" {
  count = (
    var.nsg != null && try(var.nsg.create_nic_nsg, false)
  ) ? length(var.nsg.rules) : 0

  name                        = var.nsg.rules[count.index].name
  priority                    = var.nsg.rules[count.index].priority
  direction                   = var.nsg.rules[count.index].direction
  access                      = var.nsg.rules[count.index].access
  protocol                    = var.nsg.rules[count.index].protocol
  source_port_range           = var.nsg.rules[count.index].source_port_range
  destination_port_range      = var.nsg.rules[count.index].destination_port_range
  source_address_prefix       = var.nsg.rules[count.index].source_address_prefix
  destination_address_prefix  = var.nsg.rules[count.index].destination_address_prefix

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  count = (
    var.nsg != null && try(var.nsg.create_nic_nsg, false)
  ) ? 1 : 0

  network_interface_id      = var.create_nic ? azurerm_network_interface.nic[0].id : var.network_interface_id
  network_security_group_id = azurerm_network_security_group.nsg[0].id
}



#############################################
# LINUX VM
#############################################
resource "azurerm_linux_virtual_machine" "linux" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  zone                = var.availability_zone
  admin_username      = var.admin_username

  disable_password_authentication = (
    var.admin_password == "" ? true : false
  )

  network_interface_ids = [
    var.create_nic ? azurerm_network_interface.nic[0].id : var.network_interface_id
  ]

  dynamic "admin_ssh_key" {
    for_each = var.admin_password == "" ? [1] : []
    content {
      username   = var.admin_username
      public_key = local.ssh_pub_key
    }
  }

  os_disk {
    caching              = var.os_disk_caching
    name                 = var.os_disk_name
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  identity {
    type = var.identity_type
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }


  tags = var.tags
}

#############################################
# WINDOWS VM
#############################################
resource "azurerm_windows_virtual_machine" "windows" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  zone                = var.availability_zone

  admin_username = var.admin_username
  admin_password = (
    var.admin_password != "" ?
    var.admin_password :
    data.azurerm_key_vault_secret.admin_password[0].value
  )

  network_interface_ids = [
    var.create_nic ? azurerm_network_interface.nic[0].id : var.network_interface_id
  ]

  os_disk {
    caching              = var.os_disk_caching
    name                 = var.os_disk_name
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  identity {
    type = var.identity_type
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }


  tags = var.tags
}

#############################################
# Data Disks (Create New)
#############################################
resource "azurerm_managed_disk" "data_disks" {
  for_each = {
    for d in var.data_disks : d.name => d if d.create_new
  }

  name                 = each.value.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  disk_size_gb         = each.value.disk_size_gb
  create_option        = "Empty"

  tags = var.tags
}

#############################################
# Data Disk Attach (new or existing)
#############################################
resource "azurerm_virtual_machine_data_disk_attachment" "data_attach" {
  for_each = {
    for d in var.data_disks : d.name => d
  }

  managed_disk_id = (
  lookup(each.value, "create_new", false)
    ? azurerm_managed_disk.data_disks[each.key].id
    : each.value.existing_disk_id
)


  virtual_machine_id = (
    var.os_type == "Linux"
    ? azurerm_linux_virtual_machine.linux[0].id
    : azurerm_windows_virtual_machine.windows[0].id
  )

  lun     = each.value.lun
  caching = each.value.caching
}

#############################################
# VM Extensions
#############################################
resource "azurerm_virtual_machine_extension" "extensions" {
  for_each = {
    for e in var.extensions : e.name => e
  }

  name                 = each.value.name
  publisher            = each.value.publisher
  type                 = each.value.type
  type_handler_version = each.value.type_handler_version
  settings             = jsonencode(each.value.settings)
  protected_settings   = jsonencode(each.value.protected_settings)

  virtual_machine_id = (
    var.os_type == "Linux"
    ? azurerm_linux_virtual_machine.linux[0].id
    : azurerm_windows_virtual_machine.windows[0].id
  )
}