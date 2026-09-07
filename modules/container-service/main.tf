# modules/container-service/main.tf
#
# The heart of the lab: a reusable "container-service" module that creates
# exactly one Docker container from a caller-supplied image, exposed on a
# caller-supplied host port. Everything that was hardcoded in Lab 01/02 is
# now a module input (variable), which makes this module reusable for any
# image/port combination — here we call it twice ("blue" and "green")
# from the root module.

terraform {
  # Even modules should declare the providers they rely on, so callers get
  # a clear error if the provider is not configured in the root module.
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Pull the requested image once; the container below references it by name.
resource "docker_image" "this" {
  name = var.image
}

# The single resource this module manages. The container name, the image,
# and both ports all come from variables — nothing is hardcoded.
resource "docker_container" "this" {
  name  = var.name
  image = docker_image.this.image_id

  ports {
    # internal = the port the application listens on *inside* the container
    # external = the port published on the Docker *host*
    internal = var.internal_port
    external = var.host_port
  }
}
