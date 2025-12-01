# ------------------------------------------------------------------------------
# ROUTE OUTPUTS
# ------------------------------------------------------------------------------

output "route_ids" {
  description = "Map of route keys to their route IDs"
  value       = { for k, v in aws_route.this : k => v.id }
}

output "routes" {
  description = "Map of all route attributes"
  value       = aws_route.this
}
