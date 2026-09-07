# modules/container-service/variables.tf
#
# Inputs for the container-service module. Each variable documents itself —
# this file doubles as the module's public API contract.

variable "name" {
  description = "Name of the Docker container (must be unique on the host)."
  type        = string
}

variable "image" {
  description = "Docker image to run, e.g. \"nginx:latest\"."
  type        = string
}

variable "internal_port" {
  description = "Port the application listens on inside the container."
  type        = number
}

variable "host_port" {
  description = "Port published on the Docker host (must be unique per host)."
  type        = number
}
