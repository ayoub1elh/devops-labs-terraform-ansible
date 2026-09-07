# ---------------------------------------------------------------------------
# providers.tf — Terraform and AWS provider requirements for Lab 07.
#
# This file pins the minimum Terraform version and the AWS provider so every
# learner (and the CI runner) resolves the same, current provider syntax.
# Credentials are read from the environment (AWS_ACCESS_KEY_ID /
# AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN) or from your AWS CLI profile —
# they are NEVER hardcoded in this repository.
# ---------------------------------------------------------------------------

terraform {
  # The labs were tested with Terraform 1.5+, which is also the first series
  # where the "terraform plan -destroy" and testing features we use later are
  # fully stable.
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# The AWS provider defaults to the region defined by the "aws_region"
# variable (see variables.tf). Set AWS_ACCESS_KEY_ID and
# AWS_SECRET_ACCESS_KEY in your environment, or run
# `aws configure` before `make deploy`.
provider "aws" {
  region = var.aws_region

  # Default tags applied to every resource that supports tagging. The EC2
  # instance in main.tf deliberately OVERRIDES these with its own (incomplete)
  # tags — that is one of the intentional findings this lab is built around.
  default_tags {
    tags = {
      Project   = "devops-labs"
      Lab       = "lab-07-security-scanning"
      ManagedBy = "terraform"
    }
  }
}
