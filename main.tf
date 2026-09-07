# ---------------------------------------------------------------------------
# main.tf — A deliberately "almost-correct" AWS free-tier stack for Lab 07.
#
# The stack is a minimal web server: VPC -> subnet -> security group ->
# t2.micro EC2 instance running Nginx via user_data. It is intentionally NOT
# perfect. The misconfigurations below are the learning material — the CI
# scanners (checkov, tfsec, tflint) will report them, and the lab README
# walks through reading and (properly) handling each finding:
#
#   1. The EC2 instance has monitoring = false, which triggers
#      checkov CKV_AWS_126 / tfsec aws-ec2-enable-detailed-monitoring.
#      Detailed monitoring on t2.micro is NOT free beyond the first minute,
#      so "fixing" it costs money — a classic real-world trade-off.
#   2. The EC2 instance carries incomplete tags (no Owner / Environment),
#      which most tagging policies and some custom tflint rules flag.
#   3. The security group allows HTTP (port 80) from 0.0.0.0/0 — correct for
#      a public web server, but tfsec reports it as
#      aws-ec2-no-public-ingress-sgr so you can practice judging whether a
#      finding is a true or false positive.
#
# Do NOT "fix" these until the README tells you to — the findings are the
# point of this lab.
# ---------------------------------------------------------------------------

# Fetch the latest Amazon Linux 2023 AMI so the lab does not depend on a
# hardcoded AMI ID that varies per region and goes stale over time.
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

# --- Network ---------------------------------------------------------------

resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "lab-07-vpc"
  }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "lab-07-igw"
  }
}

resource "aws_subnet" "lab" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true # public subnet: instances get a public IP

  tags = {
    Name = "lab-07-subnet"
  }
}

resource "aws_route_table" "lab" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "lab-07-rt"
  }
}

resource "aws_route_table_association" "lab" {
  subnet_id      = aws_subnet.lab.id
  route_table_id = aws_route_table.lab.id
}

# --- Security group --------------------------------------------------------

resource "aws_security_group" "web" {
  name        = "lab-07-web-sg"
  description = "Allow HTTP from anywhere and SSH only from the learner's IP"
  vpc_id      = aws_vpc.lab.id

  # HTTP from the world — legitimate for a public web server, but scanners
  # flag 0.0.0.0/0 ingress. The README shows how to evaluate this finding.
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH is locked down to the single CIDR in var.ssh_cidr. The default of
  # 0.0.0.0/32 matches nothing, which is safe if you do not need SSH.
  ingress {
    description = "SSH from learner IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab-07-web-sg"
  }
}

# --- Compute ---------------------------------------------------------------

locals {
  # Nginx install script, rendered once so it stays readable below.
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Hello from Lab 07 — Security Scanning</h1>" > /usr/share/nginx/html/index.html
  EOF
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type # t2.micro = free tier
  subnet_id              = aws_subnet.lab.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # Optional key pair: empty string means "no SSH key", which is fine because
  # Nginx is provisioned entirely by user_data.
  key_name = var.ec2_key_name != "" ? var.ec2_key_name : null

  user_data = local.user_data

  # INTENTIONAL FINDING #1: detailed monitoring is disabled. checkov reports
  # CKV_AWS_126 and tfsec reports aws-ec2-enable-detailed-monitoring. On a
  # t2.micro, enabling it would cost money (only 1 minute/day is free), so
  # this is a finding you might legitimately *suppress* rather than fix.
  monitoring = false

  # INTENTIONAL FINDING #2: this resource sets its own tags and accidentally
  # drops the provider's default tags (Owner/Environment style tags that a
  # tagging policy would expect). Note the missing "Environment" tag.
  tags = {
    Name = "lab-07-web"
    # Missing: Environment = "lab"  <- tagging-policy scanners flag this
  }

  # Replace the instance when the user_data script changes so edits are
  # actually applied on the next apply.
  user_data_replace_on_change = true
}
