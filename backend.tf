# backend.tf — controls WHERE Terraform stores its state file.
#
# Terraform state records what resources exist so it can track changes.
# This lab has two phases:
#
#   PHASE 1 (LOCAL):  the default backend. State is stored in the plain file
#                     terraform.tfstate in this directory. Good for learning,
#                     bad for teams (no locking, no sharing, easy to lose).
#
#   PHASE 2 (REMOTE): state is stored in Terraform Cloud (free tier) with
#                     locking and encryption. This is the active block below.
#
# Read README.md for the exact migration steps.

terraform {
  # ---------------------------------------------------------------------
  # PHASE 1 — LOCAL BACKEND (commented out).
  #
  # This is what Terraform does by default even with no backend block at
  # all; the block is shown here only so the migration exercise is explicit.
  # Uncomment this block (and comment the remote block) to migrate BACK
  # to local state, then run:
  #   terraform init -migrate-state
  # ---------------------------------------------------------------------
  # backend "local" {
  #   path = "terraform.tfstate"
  # }

  # ---------------------------------------------------------------------
  # PHASE 2 — REMOTE BACKEND (Terraform Cloud, active).
  #
  # >>>>> IMPORTANT: REPLACE "your-org" BELOW WITH YOUR REAL <<<<<
  # >>>>> TERRAFORM CLOUD ORGANIZATION NAME BEFORE RUNNING     <<<<<
  # >>>>> `terraform init -migrate-state`.                     <<<<<
  #
  # Steps in short (full details in README.md):
  #   1. Create a free account at https://app.terraform.io
  #   2. Create an organization (e.g. "devops-labs") — the name goes below.
  #   3. Create a workspace named "devops-labs" (or change `name` here).
  #   4. Run `terraform login` and paste an API token.
  #   5. Replace "your-org", then run `terraform init -migrate-state`.
  #
  # Free tier: Terraform Cloud's free tier includes remote state storage
  # and locking for small teams at no cost. Check current limits at
  # https://www.hashicorp.com/products/terraform/pricing
  # ---------------------------------------------------------------------
  backend "remote" {
    organization = "your-org"

    workspaces {
      # The workspace must exist in Terraform Cloud (or be auto-created
      # for allowed organizations) before `terraform init` succeeds.
      name = "devops-labs"
    }
  }
}
