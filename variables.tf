# -----------------------------------------------------------------------------
# variables.tf — Input variables for Lab 02.
#
# Every variable is fully documented with a type, a description, and a
# sensible default so `terraform plan` works out of the box. Override any
# of them by copying terraform.tfvars.example to terraform.tfvars.
# -----------------------------------------------------------------------------

variable "image_name" {
  type        = string
  description = "Name (and optionally tag) of the Docker image to deploy, e.g. 'nginx:latest' or 'nginx:1.27-alpine'."
  default     = "nginx:latest"
}

variable "host_port" {
  type        = number
  description = "Port on the host machine that will be mapped to the container's port 80. Must be free on your machine."
  default     = 8080

  validation {
    condition     = var.host_port > 0 && var.host_port < 65536
    error_message = "host_port must be a valid TCP port number between 1 and 65535."
  }
}

variable "container_name_prefix" {
  type        = string
  description = "Prefix used to build the container name. The final name is computed in locals.tf and also gets a random suffix so re-deploys never collide."
  default     = "lab02-nginx"
}
