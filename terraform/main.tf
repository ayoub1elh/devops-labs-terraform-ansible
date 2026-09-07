# main.tf — the Lab 05-style free-tier network + EC2 instance, reused for Lab 14.
#
# The ONLY change from the earlier lab is that every instance is tagged
# Environment = var.environment (default "dev"). That tag is the hook the
# amazon.aws.aws_ec2 inventory plugin uses to find hosts dynamically — no
# static inventory file is ever written by hand or by Terraform.

# Latest Ubuntu 22.04 LTS AMI for the current region (free-tier eligible).
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "lab-14-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # instances need a public IP for SSH

  tags = {
    Name        = "lab-14-subnet"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "lab-14-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "lab-14-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "web" {
  name        = "lab-14-web-sg"
  description = "Allow SSH and HTTP from the allowed CIDR blocks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "lab-14-web-sg"
    Environment = var.environment
  }
}

resource "aws_key_pair" "lab" {
  key_name   = "lab-14-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  # Minimal cloud-init: refresh the apt cache and make sure python3 exists so
  # Ansible can connect. Nginx and the MOTD are configured by the playbook —
  # NOT here — to keep the server configuration solely in Ansible's hands.
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3
  EOF

  tags = {
    Name        = "lab-14-web"
    Environment = var.environment # <- the tag the inventory plugin filters on
  }
}
