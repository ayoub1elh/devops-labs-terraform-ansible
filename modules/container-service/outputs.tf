# modules/container-service/outputs.tf
#
# Outputs of the container-service module. When the root module calls this
# module with for_each, every output becomes a map keyed by the for_each key,
# e.g. module.container_service["blue"].host_port.

output "name" {
  description = "Name of the created container."
  value       = docker_container.this.name
}

output "container_id" {
  description = "ID of the created container."
  value       = docker_container.this.id
}

output "image" {
  description = "Image in use by the container."
  value       = docker_image.this.name
}

output "host_port" {
  description = "Port published on the Docker host."
  value       = docker_container.this.ports[0].external
}

output "internal_port" {
  description = "Port the application listens on inside the container."
  value       = docker_container.this.ports[0].internal
}

output "endpoint" {
  description = "Ready-to-click HTTP endpoint for the service."
  value       = "http://localhost:${docker_container.this.ports[0].external}"
}
