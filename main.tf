# main.tf — root module for Lab 03 (Modules)
#
# This file refactors Labs 01–02 into ONE reusable module call. Instead of
# writing a docker_container resource per container, we call the local
# module "container-service" twice — once for "blue" and once for "green" —
# using for_each over a map. Adding a third container ("canary"?) is now a
# one-line change to the local.containers map.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# The for_each map: each key becomes a module instance
# (module.container_service["blue"], module.container_service["green"], ...).
# The only thing that must differ between instances on one Docker host is
# the published host port — the key itself drives the container name.
locals {
  containers = {
    blue  = { host_port = 8080 },
    green = { host_port = 8081 }
  }
}

# One module call, N containers. Terraform instantiates the module once per
# entry in local.containers; `each.key` is the map key ("blue"/"green") and
# `each.value` is the map value (an object with host_port).
module "container_service" {
  source = "./modules/container-service"

  for_each = local.containers

  name          = "lab03-${each.key}"
  image         = var.image
  internal_port = var.internal_port
  host_port     = each.value.host_port
}
