# outputs.tf — root-module outputs for Lab 03
#
# Module outputs + for_each = maps keyed by instance name. Read a single
# instance with module.container_service["blue"].host_port, or project all
# instances into one map with a for expression, as below.

output "container_names" {
  description = "Container name per instance (blue, green, ...)."
  value       = { for k, m in module.container_service : k => m.name }
}

output "endpoints" {
  description = "HTTP endpoint per instance (blue, green, ...)."
  value       = { for k, m in module.container_service : k => m.endpoint }
}

# Direct access demo: this single output shows the exact syntax for reading
# one instance's output — module.container_service["blue"].name.
output "blue_container_name" {
  description = "Name of the blue container (direct per-instance access)."
  value       = module.container_service["blue"].name
}
