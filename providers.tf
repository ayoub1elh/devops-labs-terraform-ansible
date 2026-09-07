# providers.tf — declares the required Terraform and AWS provider versions,
# plus the AWS region. Credentials are read from environment variables
# (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY) or a local AWS CLI profile,
# never from hardcoded values in this repository.

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
  # Region comes from the `aws_region` variable (default: us-east-1).
  region = var.aws_region
}
