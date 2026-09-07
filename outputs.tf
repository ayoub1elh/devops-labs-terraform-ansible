# -----------------------------------------------------------------------------
# outputs.tf — Useful values surfaced after `terraform apply` for Lab 01.
# -----------------------------------------------------------------------------

# The actual host-side port Docker published (echoed back for convenience when
# host_port = 0 and Docker chose an ephemeral port).
output "container_name" {
  description = "Name of the running Nginx container."
  value       = docker_container.nginx.name
}

output "mapped_port" {
  description = "Host port mapped to the container's port 80."
  value       = docker_container.nginx.ports[0].external
}

output "url" {
  description = "URL to curl to verify Nginx is serving."
  value       = "http://localhost:${docker_container.nginx.ports[0].external}"
}
