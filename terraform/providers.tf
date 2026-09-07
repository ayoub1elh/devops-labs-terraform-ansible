# providers.tf — pins the AWS provider for the Lab 14 free-tier infrastructure.
#
# The amazon.aws.aws_ec2 inventory plugin talks to the same AWS account using
# boto3 (installed with the collection), so the SAME credentials work for both
# Terraform and Ansible. Nothing here uses paid services.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
