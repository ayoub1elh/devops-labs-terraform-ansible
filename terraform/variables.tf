# ------------------------------------------------------------------------------
# variables.tf — input variables for Lab 13.
#
# Everything that a user might reasonably want to change (region, instance
# type, key pair, allowed SSH source) is a variable. No secrets are ever
# variables-in-git: AWS credentials come from the environment, and the SSH
# private key never leaves your machine.
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region where the lab resources are created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used for resource names and tags."
  type        = string
  default     = "lab13-web"
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro is AWS free-tier eligible."
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^t2\\.micro$|^t3\\.micro$", var.instance_type))
    error_message = "This lab is designed for free-tier instance types only: t2.micro or t3.micro."
  }
}

variable "key_name" {
  description = <<-EOT
    Name of an EXISTING AWS EC2 key pair used for SSH access. Create one with:
      aws ec2 create-key-pair --key-name lab13-key --query 'KeyMaterial' --output text > ~/.ssh/lab13-key.pem
    (or in the EC2 console: Network & Security > Key Pairs > Create key pair).
    The private key file that matches this pair is used by Ansible later.
  EOT
  type        = string

  # No default on purpose: Terraform prompts for it if not supplied via
  # tfvars or the environment. Never commit a real value to git.
}

variable "ssh_allowed_cidr" {
  description = <<-EOT
    CIDR block allowed to reach SSH (port 22). 0.0.0.0/0 works everywhere but
    is open to the whole internet — for a real setup, restrict this to your
    public IP (e.g. "203.0.113.10/32").
  EOT
  type        = string
  default     = "0.0.0.0/0"
}
