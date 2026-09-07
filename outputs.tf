# -----------------------------------------------------------------------------
# outputs.tf — Values Terraform prints after a successful apply.
#
# Outputs are how you hand information from Terraform back to the user (or
# to other Terraform configurations / scripts). Run `terraform output` at
# any time after applying to see them again.
# -----------------------------------------------------------------------------

output "container_id" {
  description = "The full ID of the running Nginx container."
  value       = docker_container.nginx.id
}

output "container_name" {
  description = "The computed name of the container (prefix + random suffix)."
  value       = docker_container.nginx.name
}

output "mapped_port" {
  description = "The host port mapped to the container's port 80."
  value       = var.host_port
}

# A ready-to-click URL, built with the format() function.
output "url" {
  description = "The URL where you can reach the Nginx welcome page."
  value       = format("http://localhost:%d", var.host_port)
}
