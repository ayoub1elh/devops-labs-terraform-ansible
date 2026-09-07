# main.tf — the actual infrastructure for lab-04-state-backends.
#
# The star of this lab is NOT the resource below — it is Terraform *state*
# (see backend.tf). We intentionally use a trivial "local_file" resource so
# the lab works on any machine with zero cloud credentials: it creates one
# small text file on disk and records it in the state backend.
#
# Free tier: costs nothing. The local_file provider needs no daemon,
# no cloud account, and no credentials.

terraform {
  # Pin a modern Terraform version. The "remote" backend in backend.tf
  # requires Terraform >= 0.12 but the rest of the lab assumes 1.x.
  required_version   = ">= 1.5.0"

  required_providers {
    # The "local" provider manages files on the machine running Terraform.
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  # NOTE: the backend block lives in backend.tf, not here. Terraform merges
  # all backend blocks and complains if it finds more than one, so we keep
  # the single source of truth in backend.tf.
}

# A single, deliberately boring resource. After `terraform apply`, look at
# the state (locally in terraform.tfstate, or in the Terraform Cloud UI
# after migration) — this resource is what you will see listed there.
resource "local_file" "lab_state_demo" {
  filename = "${path.module}/lab-output.txt"
  content  = "Managed by Terraform lab-04-state-backends. Run 'terraform state list' to see me.\n"
}
