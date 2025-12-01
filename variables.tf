# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "routes" {
  description = "Map of routes to create. Each route must specify route_table_id, destination (CIDR or prefix list), and exactly one target."
  type = map(object({
    route_table_id = string

    # Destination (one required)
    destination_cidr_block        = optional(string)
    destination_ipv6_cidr_block   = optional(string)
    destination_prefix_list_id    = optional(string)

    # Target (exactly one required)
    # Note: VPN Gateway uses gateway_id (same as Internet Gateway)
    nat_gateway_id            = optional(string)
    transit_gateway_id        = optional(string)
    vpc_peering_connection_id = optional(string)
    network_interface_id      = optional(string)
    vpc_endpoint_id           = optional(string)
    egress_only_gateway_id    = optional(string)
    gateway_id                = optional(string)
    local_gateway_id          = optional(string)
    carrier_gateway_id        = optional(string)
    core_network_arn          = optional(string)
  }))

  validation {
    condition = alltrue([
      for k, v in var.routes : (
        v.destination_cidr_block != null ||
        v.destination_ipv6_cidr_block != null ||
        v.destination_prefix_list_id != null
      )
    ])
    error_message = "Each route must specify at least one destination: destination_cidr_block, destination_ipv6_cidr_block, or destination_prefix_list_id."
  }

  validation {
    condition = alltrue([
      for k, v in var.routes : (
        (v.nat_gateway_id != null ? 1 : 0) +
        (v.transit_gateway_id != null ? 1 : 0) +
        (v.vpc_peering_connection_id != null ? 1 : 0) +
        (v.network_interface_id != null ? 1 : 0) +
        (v.vpc_endpoint_id != null ? 1 : 0) +
        (v.egress_only_gateway_id != null ? 1 : 0) +
        (v.gateway_id != null ? 1 : 0) +
        (v.local_gateway_id != null ? 1 : 0) +
        (v.carrier_gateway_id != null ? 1 : 0) +
        (v.core_network_arn != null ? 1 : 0)
      ) == 1
    ])
    error_message = "Each route must specify exactly one target (nat_gateway_id, transit_gateway_id, gateway_id, etc.)."
  }

  validation {
    condition = alltrue([
      for k, v in var.routes : can(regex("^rtb-", v.route_table_id))
    ])
    error_message = "All route_table_id values must start with 'rtb-'."
  }
}
