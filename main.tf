# ------------------------------------------------------------------------------
# ROUTES
# ------------------------------------------------------------------------------

resource "aws_route" "this" {
  for_each = var.routes

  route_table_id = each.value.route_table_id

  # Destination
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  destination_prefix_list_id  = each.value.destination_prefix_list_id

  # Targets
  nat_gateway_id             = each.value.nat_gateway_id
  transit_gateway_id         = each.value.transit_gateway_id
  vpc_peering_connection_id  = each.value.vpc_peering_connection_id
  vpn_gateway_id             = each.value.vpn_gateway_id
  network_interface_id       = each.value.network_interface_id
  vpc_endpoint_id            = each.value.vpc_endpoint_id
  egress_only_gateway_id     = each.value.egress_only_gateway_id
  gateway_id                 = each.value.gateway_id
  local_gateway_id           = each.value.local_gateway_id
  carrier_gateway_id         = each.value.carrier_gateway_id
  core_network_arn           = each.value.core_network_arn
}
