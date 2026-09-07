# =============================================================================
# main.tf — Lab 06: Terraform Workspaces
#
# Deploys the same free-tier AWS stack as Lab 05 (VPC, public subnet, internet
# gateway, route table, security group, SSH key pair, and an EC2 instance
# running Nginx) but drives every name, tag, and sizing decision from
# `terraform.workspace`. The SAME configuration therefore produces fully
# isolated `dev` and `staging` environments with zero code duplication.
#
# Each workspace keeps its own state file locally under
# terraform.tfstate.d/<workspace>/ (see backend.tf).
# =============================================================================

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
  region = var.aws_region

  # Applied to every resource this lab creates. Because `local.environment`
  # comes from terraform.workspace, each workspace's resources are tagged
  # differently in the AWS console for free — that is what makes the two
  # environments easy to tell apart during verification.
  default_tags {
    tags = {
      Project     = "devops-labs-terraform-ansible"
      Lab         = "lab-06-workspaces"
      Environment = local.environment
      ManagedBy   = "terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# Workspace-driven configuration map.
#
# Adding a new environment is a one-line change here plus
# `terraform workspace new <name>`. The lookup() gives the `default`
# workspace dev-like behavior so a bare `terraform plan` still works instead
# of crashing on a missing map key — but real environments should always use
# a named workspace.
# -----------------------------------------------------------------------------
locals {
  workspace_config = {
    dev = {
      instance_type = "t2.micro"
      environment   = "dev"
    }
    staging = {
      # t3.micro is the free-tier instance family in some newer regions, but
      # t2.micro is free-tier eligible everywhere, so it is the safe shared
      # choice for both workspaces.
      instance_type = "t2.micro"
      environment   = "staging"
    }
  }

  workspace_settings = lookup(local.workspace_config, terraform.workspace, local.workspace_config["dev"])
  instance_type      = local.workspace_settings.instance_type
  environment        = local.workspace_settings.environment

  # Every resource name carries the workspace so two workspaces can never
  # collide inside the same AWS account/region.
  name_prefix = "lab-06-${terraform.workspace}"
}

# Latest Amazon Linux 2023 AMI (free-tier eligible, x86_64, HVM).
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SSH key pair — the public key is supplied via variable, never hardcoded.
resource "aws_key_pair" "lab" {
  key_name   = "${local.name_prefix}-key"
  public_key = var.ssh_public_key
}

# --- Network -----------------------------------------------------------------

resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "lab" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "${local.name_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_route_table" "lab" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "${local.name_prefix}-rt"
  }
}

resource "aws_route_table_association" "lab" {
  subnet_id      = aws_subnet.lab.id
  route_table_id = aws_route_table.lab.id
}

# --- Security ----------------------------------------------------------------

resource "aws_security_group" "lab" {
  name        = "${local.name_prefix}-sg"
  description = "Allow SSH from a trusted CIDR and HTTP from anywhere (${terraform.workspace})"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg"
  }
}

# --- Compute -----------------------------------------------------------------

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = local.instance_type # from the workspace map
  subnet_id                   = aws_subnet.lab.id
  vpc_security_group_ids      = [aws_security_group.lab.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  # Installs Nginx and serves a page that echoes the workspace name, which
  # makes the "same code, two isolated environments" story trivially
  # verifiable in a browser or with curl.
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Lab 06 - Terraform workspaces</h1><p>Workspace: ${terraform.workspace}</p><p>Environment: ${local.environment}</p>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name        = "${local.name_prefix}-web"
    Environment = local.environment
  }
}

# --- Outputs -----------------------------------------------------------------

output "workspace" {
  description = "The workspace this deployment belongs to."
  value       = terraform.workspace
}

output "environment" {
  description = "Environment tag value, driven by the workspace map."
  value       = local.environment
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance (differs per workspace)."
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.web.public_dns
}

output "instance_tags" {
  description = "Tags applied to the instance — compare these across workspaces."
  value       = aws_instance.web.tags
}

output "ssh_command" {
  description = "Command to SSH into the instance as the ec2-user."
  value       = "ssh -i <path-to-your-private-key> ec2-user@${aws_instance.web.public_ip}"
}
