# =============================================================================
# backend.tf — Lab 06: Terraform Workspaces
#
# Uses the local backend so each workspace gets its own isolated state file:
#
#   terraform.tfstate.d/dev/terraform.tfstate
#   terraform.tfstate.d/staging/terraform.tfstate
#
# Moving to a shared remote backend later (recommended once a team is
# involved) is a two-step process:
#
#   1. Create the backend infrastructure once, e.g. an S3 bucket with
#      versioning + encryption and a DynamoDB table for state locking
#      (create those with a small one-off configuration first).
#
#   2. Replace the backend block below with, for example:
#
#        terraform {
#          backend "s3" {
#            bucket         = "my-lab-terraform-state"
#            key            = "lab-06-workspaces/terraform.tfstate"
#            region         = "us-east-1"
#            dynamodb_table = "terraform-locks"
#            encrypt        = true
#          }
#        }
#
#      then run `terraform init -migrate-state` and approve the migration.
#      Terraform copies EACH workspace's state into the remote backend, so
#      the dev/staging isolation you see locally carries over unchanged.
#
# Until then: keep terraform.tfstate.d/ out of git (see .gitignore) and never
# commit state files — they can contain sensitive data.
# =============================================================================

terraform {
  backend "local" {
    # No path argument: the local backend stores one state file per
    # workspace under terraform.tfstate.d/<workspace-name>/ automatically.
  }
}
