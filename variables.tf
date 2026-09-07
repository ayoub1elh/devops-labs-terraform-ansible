# ---------------------------------------------------------------------------
# variables.tf — Input variables for the Lab 07 AWS free-tier stack.
#
# Everything that a learner might reasonably want to change (region, CIDRs,
# instance type) is a variable so the code stays portable and no value that
# could differ between environments is buried in main.tf.
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region where all resources are created. us-east-1 keeps us on the free tier with the widest AMI availability."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.70.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet inside the lab VPC."
  type        = string
  default     = "10.70.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro is the only type covered by the AWS 12-month free tier for new accounts."
  type        = string
  default     = "t2.micro"
}

variable "ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict this to your own public IP (e.g. \"203.0.113.10/32\") — never use 0.0.0.0/0 for SSH."
  type        = string
  default     = "0.0.0.0/32" # deliberately closed by default; set to your IP in terraform.tfvars
}

variable "ec2_key_name" {
  description = "Name of an existing EC2 key pair used for SSH access. Leave empty (\"\") to create the instance without any key pair — the lab works without SSH because Nginx is installed via user_data."
  type        = string
  default     = ""
}
