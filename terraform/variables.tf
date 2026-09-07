# variables.tf — Input variables for the Lab 17 capstone infrastructure.
# No secrets ever live here; the EC2 key pair name is supplied via
# TF_VAR_key_name / -var / terraform.tfvars (see terraform.tfvars.example).

variable "aws_region" {
  description = "AWS region where all resources are created. Must match the region used by the Ansible aws_ec2 dynamic inventory."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro / t2.micro are AWS Free Tier eligible."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing AWS EC2 key pair used for SSH access. Pass via TF_VAR_key_name or terraform.tfvars — never commit the private key."
  type        = string
  # No default on purpose: SSH access is impossible without it, so fail fast.
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict to your own IP (e.g. 203.0.113.10/32) for anything beyond a throwaway lab."
  type        = string
  default     = "0.0.0.0/0"
}
