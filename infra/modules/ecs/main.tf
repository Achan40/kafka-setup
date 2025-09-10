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

# ECS setup
# 1. Create an ECS cluster
# 2. ECS cluster needs infrastructure to run on (EC2,fargate). In our case we use EC2.
# 3. Create security group, allows for traffic in/out EC2 instances
# 4. Create IAM role/policy/instance_profile to allow EC2 instances to communicate with ECS resources
# 5. Create launch template. Basically a guide for how to provision EC2 resources. Attach IAM role, sec group to this template so that
# AWS knows how to create your instances
# 6. Configure subnets and create autoscaling group. The autoscaling group will determine how/when to launch new EC2 instances
# 7. Create ECS capacity providers and link to auto scaling group. ECS will now determine how to scale your resources.


# create ECS cluster for serving containers
resource "aws_ecs_cluster" "kafka_setup_cluster" {
  name = var.ecs_cluster_name
  tags = {
    Name = var.project_tag
  }
}

# EC2 cluster needs infrastructure to run on, either EC2 or fargate
#### configure security groups and EC2 infrastructure ####
# Fetch current public IP dynamically
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Clean up the result 
locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

# Security group allowing SSH into EC2 instances only from *your* IP
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-ssh-sg"
  description = "Allow SSH from my current public IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true  # allows traffic from other instances in the same SG
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

# IAM Role, attach policy, instance profiles for EC2 instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

# Launch Template for ECS Instances
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-lt-"
  image_id      = data.aws_ami.ecs.id # ECS-optimized AMI
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<-EOT
              #!/bin/bash
              echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
              EOT
  )
}

## configure subnets
# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "ecs-asg"
  max_size                  = 3
  min_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = data.aws_subnets.default.ids # replace with your subnet(s)
  health_check_type         = "EC2"

  # Enable new instances to have scale-in protection
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

# Capacity Provider
resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "kafka-setup-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }
  }
}

# Link Capacity Provider to ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name       = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    weight            = 1
    base              = 1
  }
}