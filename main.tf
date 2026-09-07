# -----------------------------------------------------------------------------
# main.tf — Lab 01: Docker provider
#
# Deploys a single Nginx container on the local Docker daemon using the
# kreuzwerker/docker Terraform provider. The host port is configurable via the
# `host_port` variable and is published to the container's port 80.
# -----------------------------------------------------------------------------

terraform {
  # Pin the Terraform CLI version this configuration was written/tested with.
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Connect to the local Docker daemon. On Linux you may need to point the
# provider at a non-default socket (e.g. in rootless mode) — override the
# `docker_host` variable in a *.tfvars file or TF_VAR_docker_host instead of
# editing this file.
provider "docker" {
  host = var.docker_host
}

# Pull the Nginx image once, so the container creation below never has to
# wait on an implicit pull.
resource "docker_image" "nginx" {
  name = "nginx:latest"

  # Force re-pull when the tag is updated upstream, so "latest" actually
  # stays fresh across applies.
  keep_locally = false
}

# The Nginx container itself. `external = 0` (the default) asks Docker to
# pick a free ephemeral host port; set `host_port` in terraform.tfvars to
# pin a fixed port such as 8080.
resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80 # Nginx listens on port 80 inside the container.
    external = var.host_port
    ip       = "127.0.0.1" # Bind to localhost only — safer on shared machines.
  }
}
