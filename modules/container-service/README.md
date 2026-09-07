# container-service

A small, reusable Terraform module that runs a single Docker container and
publishes one port. It is the building block used by Lab 03's root module to
deploy a "blue" and a "green" container from the same code.

## Usage

```hcl
module "web" {
  source = "./modules/container-service"

  name          = "web-blue"
  image         = "nginx:latest"
  internal_port = 80
  host_port     = 8080
}
```

Call it multiple times (directly or with `for_each`) to spin up as many
identically-shaped services as you need — only the inputs change.

## Inputs

| Name            | Description                                              | Type     | Required |
|-----------------|----------------------------------------------------------|----------|----------|
| `name`          | Name of the Docker container (must be unique on the host).| `string` | yes      |
| `image`         | Docker image to run, e.g. `"nginx:latest"`.              | `string` | yes      |
| `internal_port` | Port the application listens on inside the container.    | `number` | yes      |
| `host_port`     | Port published on the Docker host (unique per host).     | `number` | yes      |

## Outputs

| Name            | Description                                   |
|-----------------|-----------------------------------------------|
| `name`          | Name of the created container.                |
| `container_id`  | ID of the created container.                  |
| `image`         | Image in use by the container.                |
| `host_port`     | Port published on the Docker host.            |
| `internal_port` | Port the application listens on inside.       |
| `endpoint`      | Ready-to-click `http://localhost:<port>` URL. |

## Notes

* No secrets are involved — do not add provider credentials here; the Docker
  provider uses the ambient Docker daemon socket.
* The module intentionally manages exactly one container. Composing several
  instances is the caller's job (see `for_each` in the root module).
