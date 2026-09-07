# -----------------------------------------------------------------------------
# variables.tf — Input variables for Lab 01 (Docker provider).
#
# No secrets are needed anywhere in this lab: the Docker provider talks to the
# local daemon over a socket, so every variable is a plain configuration knob.
# -----------------------------------------------------------------------------

variable "docker_host" {
  description = "Docker daemon address (override in rootless or remote setups)."
  type        = string
  default     = "unix:///var/run/docker.sock"

  # Only override this if your Docker socket lives somewhere non-standard,
  # e.g. rootless Docker: unix:///run/user/1000/docker.sock
  # or Docker Desktop on Windows via the TCP relay.
}

variable "host_port" {
  description = "Host port published to the container's port 80. Use 0 to let Docker pick a free port."
  type        = number
  default     = 0

  validation {
    condition     = var.host_port >= 0 && var.host_port <= 65535
    error_message = "host_port must be between 0 and 65535 (0 = auto-assign)."
  }
}

variable "container_name" {
  description = "Name given to the Nginx container."
  type        = string
  default     = "lab-01-nginx"
}
