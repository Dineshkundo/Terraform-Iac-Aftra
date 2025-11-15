variable "vnet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(object({
    name           = string
    address_prefix = string

    nsg_id         = optional(string)
    route_table_id = optional(string)

    # Correct v4.52 attributes
    enforce_private_link_endpoint_network_policies = optional(bool, false)
    enforce_private_link_service_network_policies  = optional(bool, false)

    service_endpoints = list(string)

    delegations = optional(list(object({
      name         = string
      service_name = string
    })), [])
  }))
}

variable "peerings" {
  type = map(object({
    name                    = string
    remote_vnet_id          = string
    allow_vnet_access       = bool
    allow_forwarded_traffic = bool
    allow_gateway_transit   = bool
    use_remote_gateways     = bool
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
