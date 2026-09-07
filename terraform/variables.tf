# variables.tf — input variables for the Lab 14 infrastructure.
#
# Nothing secret lives here. The AWS credentials come from environment
# variables (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY), never from tfvars.

variable "aws_region" {
  description = "AWS region for all resources. Must match the region the inventory plugin queries."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Value of the Environment tag. The aws_ec2 inventory plugin filters on this, so only instances tagged Environment=dev are inventoried."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type — t2.micro is AWS Free Tier eligible."
  type        = string
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to the SSH public key uploaded to AWS as a key pair. Generate one with: ssh-keygen -t ed25519 -f ~/.ssh/devops-labs"
  type        = string
  default     = "~/.ssh/devops-labs.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (port 22). Restrict to your IP, e.g. '203.0.113.10/32', in anything but a throwaway lab."
  type        = string
  default     = "0.0.0.0/0"
}
