# main.tf — AWS Free Tier lab infrastructure.
#
# Builds, from scratch, in a single region:
#   1 VPC -> 1 public subnet -> 1 Internet Gateway -> 1 route table
#   -> 1 security group (SSH from your IP, HTTP from anywhere)
#   -> 1 key pair -> 1 t2.micro EC2 instance running Nginx via user_data.
#
# Everything here stays inside the AWS Free Tier: a t2.micro instance,
# a default-size EBS root volume, no NAT Gateway, no load balancer,
# no provisioned-IOPS storage. See the README "Free Tier Notes" section.

# ---------------------------------------------------------------------------
# Networking: VPC, subnet, Internet Gateway, route table
# ---------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # required so the instance can resolve names
  enable_dns_hostnames = true # gives the instance a public DNS name

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true # instances launched here get a public IP automatically

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route table sends all non-local traffic (0.0.0.0/0) out through the IGW,
# which is what makes the subnet "public" and lets Nginx answer the internet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Data lookups (no resources created here — nothing billable)
# ---------------------------------------------------------------------------

# Ubuntu 22.04 LTS published by Canonical (owner 099720109477).
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ---------------------------------------------------------------------------
# Security group
# ---------------------------------------------------------------------------
# SSH (22) is restricted to the allowed_ssh_cidr variable — set it to your
# own /32 IP. HTTP (80) is open to the world because that is the point of
# a public web server. Everything else is denied by default.
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH from admin IP and HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the allowed admin CIDR only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic (apt, Nginx, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# ---------------------------------------------------------------------------
# Key pair — reads the *public* key from your local machine
# ---------------------------------------------------------------------------

resource "aws_key_pair" "admin" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))

  tags = {
    Name = "${var.project_name}-key"
  }
}

# ---------------------------------------------------------------------------
# EC2 instance — the only resource that accrues Free Tier hours
# ---------------------------------------------------------------------------

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type # t2.micro = Free Tier eligible
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.admin.key_name
  associate_public_ip_address = true

  # Root EBS volume: default 8 GB gp2/gp3 stays inside the 30 GB/month
  # Free Tier allowance. Do NOT change volume_type to provisioned IOPS.
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  # Runs once at first boot: install Nginx, drop a custom landing page,
  # and make sure the service is up.
  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y nginx
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
      <head><title>lab-05-aws-free-tier</title></head>
      <body>
        <h1>It works! Nginx on AWS Free Tier (Terraform-managed)</h1>
      </body>
    </html>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "${var.project_name}-web"
  }
}
