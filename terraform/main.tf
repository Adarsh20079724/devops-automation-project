terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# VPC - Using default VPC for simplicity
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "devops-automation-sg"
  description = "Security group for DevOps automation project"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access for the app
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Application access"
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name    = "devops-automation-sg"
    Project = "DevOps-Automation"
  }
}



# Key Pair
resource "aws_key_pair" "app_key" {
  key_name   = var.key_name
  public_key = var.public_key

  tags = {
    Name    = "devops-automation-key"
    Project = "DevOps-Automation"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.app_key.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = file("${path.module}/scripts/setup.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "devops-automation-server"
    Project = "DevOps-Automation"
  }
}

