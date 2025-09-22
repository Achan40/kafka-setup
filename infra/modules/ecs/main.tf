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
# 8. Create a service discovery private dns namespace. Use so services can create a resolvable dns within the VPC

# 1. Create an ECS cluster
resource "aws_ecs_cluster" "kafka_setup_cluster" {
  name = var.ecs_cluster_name
  tags = {
    Name = var.project_tag
  }
}

# 2-3.
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

# Look up the managed prefix list for EC2 Instance Connect in this region
data "aws_ec2_managed_prefix_list" "ec2_instance_connect" {
  name = "com.amazonaws.${var.aws_region}.ec2-instance-connect"
}


# Security group allowing SSH into EC2 instances only from *your* IP
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-ssh-sg"
  description = "Allow SSH from my current public IP"
  vpc_id      = data.aws_vpc.default.id

  # allow from local ip (with generated ssh key)
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  # Allow SSH from the EC2 Instance Connect service (console/web terminal)
  ingress {
    description      = "EC2 Instance Connect service"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    prefix_list_ids  = [data.aws_ec2_managed_prefix_list.ec2_instance_connect.id]
  }

  # open port 9093 to self
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block] 
  }
    
  ingress {
    from_port   = 29092
    to_port     = 29092
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block] 
  }

  # Allow all traffic between instances in this SG
  ingress {
    description      = "Allow all traffic between ECS instances"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = [data.aws_vpc.default.cidr_block] # open to all in VPC
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Create IAM role/policy/instance_profile to allow EC2 instances to communicate with ECS resources
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

# Add EC2 Instance Connect permissions
resource "aws_iam_role_policy_attachment" "ecs_instance_role_ec2_instance_connect" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceConnect"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

# 5. Create launch template.
# Data source to fetch the latest ECS-optimized Amazon Linux 2 AMI
# Fetch the latest Amazon Linux 2023 ECS-Optimized AMI (general-purpose, non-GPU)
data "aws_ssm_parameter" "ecs_al2023_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# Launch Template for ECS Instances
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-lt-"
  image_id      = data.aws_ssm_parameter.ecs_al2023_ami.value # ECS-Optimized AL2023 AMI
  instance_type = var.ec2_instance_type
  key_name      = "ecs-key"  # replace with your key pair
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<-EOT
              #!/bin/bash
              echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config

              # Update packages
              sudo dnf update -y

              # Install EC2 Instance Connect
              sudo dnf install -y ec2-instance-connect

              # Install nc
              sudo yum install nc -y

              # temporarily create host path
              sudo mkdir -p /mnt/kafka-data
              sudo chown -R ec2-user:ec2-user /mnt/kafka-data
              EOT
  )
}

# 6. Configure subnets and create autoscaling group.
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
  max_size                  = var.ec2_instance_max
  min_size                  = var.ec2_instance_min
  desired_capacity          = var.ec2_instance_min
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

# 7. Create ECS capacity providers and link to auto scaling group. 
# Capacity Provider
resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "kafka-setup-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
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

# 8. Create a service discovery private dns namespace
# Use so services can create a resolvable dns on within the VPC
resource "aws_service_discovery_private_dns_namespace" "ecs_private_dns_ns" {
  name        = "ecs.local"
  description = "Private namespace for ECS cluster"
  vpc         = data.aws_vpc.default.id
}