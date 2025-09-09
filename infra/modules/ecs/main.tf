terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }
  backend "s3" {
  }
}

# set up ECS cluster for serving containers
resource "aws_ecs_cluster" "kafka_setup_cluster" {
  name = var.ecs_cluster_name
  tags = {
    Name = var.project_tag
  }
}

#### configure security groups and EC2 infrastructure ####
# Fetch current public IP dynamically
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Clean up the result (it comes with a newline)
locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

# Security group allowing SSH only from *your* IP
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-ssh-sg"
  description = "Allow SSH from my current public IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source to fetch the latest ECS-optimized Amazon Linux 2 AMI
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# ECS-optimized EC2 instance
resource "aws_instance" "ecs_instance" {
  ami           = data.aws_ami.ecs.id
  instance_type = "t3.micro"        # minimal size

  # Optional: SSH key
  key_name = "ecs-key"  # replace with your key pair
  vpc_security_group_ids      = [aws_security_group.ecs_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ECSInstance"
  }
}