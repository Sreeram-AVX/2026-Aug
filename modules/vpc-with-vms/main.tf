# =============================================================================
# VPC + 2 VMs Module
# =============================================================================
# This module creates:
#   1. A VPC (Virtual Private Cloud)
#   2. A public subnet
#   3. A private subnet
#   4. An Internet Gateway (for public internet access)
#   5. Route tables for each subnet
#   6. Two EC2 instances — one in each subnet
#   7. Security groups for each VM
# =============================================================================

# --- VPC ---
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# --- Subnets ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# --- Internet Gateway (allows public subnet to reach the internet) ---
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- Route Tables ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security Groups ---
resource "aws_security_group" "public_vm" {
  name_prefix = "${var.project_name}-public-vm-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-public-vm-sg"
  }
}

resource "aws_security_group" "private_vm" {
  name_prefix = "${var.project_name}-private-vm-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "SSH from public VM"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_vm.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-vm-sg"
  }
}

# --- EC2 Instances (VMs) ---
resource "aws_instance" "public_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_vm.id]
  key_name               = var.key_name

  tags = {
    Name = "${var.project_name}-public-vm"
    Role = "bastion"
  }
}

resource "aws_instance" "private_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_vm.id]
  key_name               = var.key_name

  tags = {
    Name = "${var.project_name}-private-vm"
    Role = "application"
  }
}