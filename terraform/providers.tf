# ------------------------------------------------------------------------------
# providers.tf — provider configuration for Lab 13.
#
# Pins the AWS provider and sets a region plus default resource tags so every
# resource carries a Name/Project tag in the AWS console.
#
# Credentials are NOT stored here. Terraform reads them from standard AWS
# environment variables (see the lab README):
#   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (+ optional AWS_SESSION_TOKEN)
# or from a shared credentials file (~/.aws/credentials).
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Default tags applied to every taggable resource. Makes it easy to spot
  # (and delete) lab resources in the AWS console.
  default_tags {
    tags = {
      Project = "devops-labs"
      Lab     = "lab-13-tf-ansible-integration"
      Managed = "terraform"
    }
  }
}
