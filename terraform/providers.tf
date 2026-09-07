# providers.tf — Terraform and provider version constraints for Lab 17.
# AWS provider ~> 5.0 (current major), local provider is used to render the
# static Ansible inventory file (carried over from Lab 13).

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

  # default_tags are applied to every taggable resource; the Environment tag
  # is what the Ansible dynamic inventory plugin filters on (Lab 14 tag).
  default_tags {
    tags = {
      Project     = "devops-labs"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
