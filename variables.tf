# variables.tf — every tunable value for this lab. Nothing secret lives here;
# the SSH *public* key is safe to keep in version control, but the matching
# private key must never be committed.

variable "aws_region" {
  description = "AWS region where all resources are created. us-east-1 has the widest Free Tier AMI coverage."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro is the only type covered by the AWS Free Tier."
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict this to YOUR public IP (/32) to avoid brute-force noise."
  type        = string
  default     = "203.0.113.10/32" # placeholder — replace with your IP, see README

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid CIDR block, e.g. 203.0.113.10/32."
  }
}

variable "ssh_public_key_path" {
  description = "Path to the SSH *public* key on your local machine. Used to create the AWS key pair for instance access."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "project_name" {
  description = "Prefix used to name/tag all resources so they are easy to find and to delete."
  type        = string
  default     = "lab-05-free-tier"
}
