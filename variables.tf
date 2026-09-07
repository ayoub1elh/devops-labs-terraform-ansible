# variables.tf — root-module inputs for Lab 03
#
# Values shared by ALL module instances live here (image, internal port),
# so the for_each map only has to carry what differs per instance
# (the host port). Override them with -var flags or a *.tfvars file.

variable "image" {
  description = "Docker image used for every container-service instance."
  type        = string
  default     = "nginx:latest"
}

variable "internal_port" {
  description = "Port Nginx listens on inside every container."
  type        = number
  default     = 80
}
