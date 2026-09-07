# variables.tf — all input variables for Lab 08.
#
# Nothing secret lives here: credentials come from the environment
# (locally via `aws configure`, in CI via OIDC), never from tfvars files.

variable "aws_region" {
  description = "AWS region where all resources are created. us-east-1 is used by default because it has the most complete free-tier support."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix applied to every resource and tag so the lab is easy to identify (and delete) in the AWS console."
  type        = string
  default     = "lab08-cicd"
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro is free-tier eligible for 12 months (750 hours/month)."
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance. Override in terraform.tfvars to your own IP (https://whatismyip.com) — do NOT leave 0.0.0.0/0 for anything other than this throwaway lab."
  type        = string
  default     = "0.0.0.0/0"
}
