# providers.tf — Terraform and AWS provider configuration for Lab 08.
#
# This lab keeps the default "local" backend (state file on disk) so it runs
# anywhere with zero setup. That is fine for learning, but it has a big catch
# in CI: the GitHub Actions runner is a fresh VM on every run, so `plan` on a
# pull request and `apply` on merge do NOT share state. For real projects use
# a remote backend (S3 + DynamoDB lock, or Terraform Cloud free tier) — see
# the README, "State backend for CI" section.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
      Lab       = "lab-08-terraform-cicd"
    }
  }
}

# ---------------------------------------------------------------------------
# OPTION B (alternative to oidc.tf in this lab): reference an OIDC provider
# that ALREADY EXISTS in the account instead of creating one. If you created
# the OIDC provider and IAM role manually in the AWS console (Option A in the
# README), this data lookup lets Terraform read it without owning it:
#
#   data "aws_iam_openid_connect_provider" "github" {
#     url = "https://token.actions.githubusercontent.com"
#   }
#
# You could then reference its ARN in outputs, e.g.:
#   output "github_oidc_provider_arn" {
#     value = data.aws_iam_openid_connect_provider.github.arn
#   }
#
# This lab uses OPTION A: oidc.tf creates the provider + role for you, so
# the block above is commented out. Never enable both at once — you would
# get a "provider already exists" error on apply.
# ---------------------------------------------------------------------------
