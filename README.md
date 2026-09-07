# Lab 02 — Variables, Locals & Outputs

In Lab 01 you deployed an Nginx container with everything hardcoded. Real Terraform code doesn't work that way: this lab rebuilds the exact same container, but the image name, host port, and container name prefix are all **input variables** (optionally set in a `terraform.tfvars` file), the final container name is computed with **locals**, and useful values are exposed as **outputs** — including a ready-to-click URL built with the `format()` function.

## Learning Objectives

By the end of this lab you will be able to:

- Declare Terraform variables with `type`, `description`, and `default` values
- Override variables using a `terraform.tfvars` file (from `terraform.tfvars.example`)
- Add input validation to variables (`validation` blocks)
- Combine variables, resources, and functions into computed values using `locals`
- Understand why `random_id` beats `timestamp()` for stable unique names
- Define outputs and build formatted strings with `format()`
- Query outputs after apply with `terraform output`

## Architecture

```mermaid
flowchart LR
    subgraph Terraform["Terraform Configuration"]
        V[variables.tf<br/>image_name, host_port,<br/>container_name_prefix]
        L[locals.tf<br/>computed container_name]
        M[main.tf<br/>random_id + docker_image<br/>+ docker_container]
        O[outputs.tf<br/>id, name, port, URL]
        V --> L
        L --> M
        M --> O
    end
    subgraph Docker["Docker (local, free)"]
        IMG[(nginx image)]
        C[nginx container<br/>:80 -> host_port]
    end
    TFVARS[(terraform.tfvars<br/>(gitignored))]
    TFVARS -.overrides.-> V
    M --> IMG
    M --> C
    USER([You]) -->|"curl http://localhost:8080"| C
```

## Prerequisites

| Tool | Version (tested) | Notes |
|------|------------------|-------|
| Git | any recent | to clone the repo |
| Terraform | >= 1.5.0 | `terraform -version` to check |
| Docker Desktop / Docker Engine | any recent | must be **running** |
| make | any GNU/BSD make | optional — all steps work as plain commands too |
| curl | any | for verification (or just open the URL in a browser) |

- **Free accounts needed:** none. This lab runs only on your local Docker daemon — no AWS, no Terraform Cloud, no API keys, no environment variables.
- **Required environment variables:** none.

## Step-by-Step Instructions

All commands run from the lab directory (the folder containing this README).

**1. Verify prerequisites**

```bash
make setup
```

Expected output (versions will vary):

```
Checking prerequisites...
Terraform v1.9.x
Docker version 27.x.x
All prerequisites OK.
```

**2. (Optional) Create your tfvars file**

The lab works with defaults, but creating a tfvars file is the point of this exercise:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and change at least one value, for example:

```hcl
host_port             = 9090
container_name_prefix = "my-lab02"
```

> `terraform.tfvars` is gitignored (see `.gitignore`) — your overrides stay local.

**3. Look at the plan**

```bash
terraform init
terraform plan
```

In the plan, notice that the container **name** is computed — you should see something like `+ name = "my-lab02-a1b2c3d4"` (your suffix will differ). This value comes from `locals.tf`.

**4. Apply**

```bash
terraform apply
```

Type `yes` when prompted. Expected output (abbreviated):

```
random_id.name_suffix: Creation complete ...
docker_image.nginx: Creation complete ...
docker_container.nginx: Creation complete ...

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

container_id = "f3d4..."
container_name = "my-lab02-a1b2c3d4"
mapped_port = 9090
url = "http://localhost:9090"
```

(Or simply `make deploy`, which does init → plan → apply for you.)

**5. Inspect the outputs on demand**

```bash
terraform output
terraform output -raw url
```

The second command prints just the URL — a pattern you will reuse in scripts and later labs.

## How Do I Know This Worked?

**1. The outputs exist:**

```bash
terraform output url
# "http://localhost:9090"
```

**2. The container is actually running with the computed name:**

```bash
docker ps --filter "name=$(terraform output -raw container_name)"
```

You should see your container, with `0.0.0.0:9090->80/tcp` in the PORTS column.

**3. Nginx serves the welcome page:**

```bash
curl "$(terraform output -raw url)"
```

Expected: HTML containing `<title>Welcome to nginx!</title>`.

**4. (Bonus) Variables drive the plan.** Change `host_port` in `terraform.tfvars` and run `terraform plan` again — Terraform should show it will **replace** the container to apply the new port, because the port is a variable-driven argument.

## Cleanup

Tear down the container and remove local state:

```bash
terraform destroy    # type yes, or: terraform destroy -auto-approve
make clean           # removes .terraform/, state files, lock file
```

Then verify nothing is left:

```bash
docker ps -a --filter "name=lab02"
terraform state list
```

Both should return empty results (the second will error with "No state file was found" — that's expected after `make clean`).

## Troubleshooting

**1. `Error: Error response from daemon: port is already allocated`**

- **Symptom:** apply fails when creating the container.
- **Cause:** another container (or app) already uses `host_port`.
- **Fix:** pick a different port in `terraform.tfvars` (e.g. `host_port = 9091`) and re-run `terraform apply`. Find the conflict with `docker ps` or `netstat -ano | grep <port>`.

**2. `Error: Invalid value for variable: host_port must be a valid TCP port number...`**

- **Symptom:** `terraform plan` fails before planning anything.
- **Cause:** you set `host_port` in `terraform.tfvars` to something outside 1–65535 (e.g. `0`, `70000`, or a string).
- **Fix:** fix the value in `terraform.tfvars`. This error comes from the `validation` block in `variables.tf` — a habit worth building early.

**3. `terraform plan` always wants to replace the container, even when nothing changed**

- **Symptom:** every plan shows `-/+ docker_container.nginx` with the name changing.
- **Cause:** the container name was built with `timestamp()` (or another value that changes each run) instead of a stable random suffix. Terraform sees a "new" name and plans replacement forever — a perpetual diff.
- **Fix:** this lab already does it right — see the comment in `locals.tf`. If you experiment and hit this, build the name from `random_id.name_suffix.hex` (stored in state, stable between runs) instead of `timestamp()`.

## Free Tier Notes

- This lab creates **only a local Docker container** — there are no cloud resources and **zero cost** beyond your own machine.
- No AWS or Terraform Cloud accounts are used, so there is nothing to check in a billing console for this lab.
- General warning (applies to the later cloud labs in this repo): **cloud free tiers change over time**. Whenever a lab does create cloud resources, always run `make destroy`/`terraform destroy` when finished, and check the provider's billing console afterwards.
