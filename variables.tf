# =============================================================================
# variables.tf — Lab 06: Terraform Workspaces
#
# All user-supplied inputs for this lab. AWS credentials are NOT a variable:
# they are read from the standard environment variables
# (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY) or an AWS CLI profile, and the
# SSH public key can also be passed via TF_VAR_ssh_public_key so it never
# touches disk inside this repository.
# =============================================================================

variable "aws_region" {
  description = "AWS region where every workspace's resources are created."
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet. Must exist in var.aws_region."
  type        = string
  default     = "us-east-1a"
}

variable "ssh_public_key" {
  description = "SSH public key material (e.g. 'ssh-ed25519 AAAA...') used for the EC2 key pair in every workspace."
  type        = string
  # No default on purpose: pass it via -var, TF_VAR_ssh_public_key, or a
  # gitignored terraform.tfvars file.
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to reach port 22. Restrict this to your own public IP for anything beyond this lab."
  type        = string
  default     = "0.0.0.0/0"
}
