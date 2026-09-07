# -----------------------------------------------------------------------------
# main.tf — Lab 02: Variables, Locals & Outputs.
#
# Same Nginx container as Lab 01, but nothing is hardcoded: the image, the
# host port, and the container name all come from variables.tf (optionally
# overridden via terraform.tfvars) and are combined in locals.tf.
#
# Requires: Docker Desktop (or Docker Engine) running locally.
# -----------------------------------------------------------------------------

terraform {
  # Pin the Terraform language version for reproducibility.
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# The docker provider talks to the local Docker daemon. On Windows/macOS it
# finds Docker Desktop automatically; on Linux set DOCKER_HOST if needed.
provider "docker" {}

provider "random" {}

# Generates a stable random suffix that lives in the Terraform state, so the
# container name is unique but does not change on every plan (unlike
# timestamp()). See locals.tf for how it is used.
resource "random_id" "name_suffix" {
  byte_length = 4
}

# Pull the image named by var.image_name. keep_locally = true avoids
# re-downloading the image every apply.
resource "docker_image" "nginx" {
  name         = var.image_name
  keep_locally = true
}

# Run the container. The name comes from the local computed in locals.tf,
# and the published port comes from var.host_port.
resource "docker_container" "nginx" {
  name  = local.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.host_port
  }
}
