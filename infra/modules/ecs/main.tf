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

resource "aws_ecs_cluster" "kafka_setup_cluster" {
  name = var.ecs_cluster_name
  tags = {
    Name = var.project_tag
  }
}

### Configure security groups and EC2 infrastructure ###
# Use an existing VPC
data "aws_vpc" "custom_vpc" {
  id = var.vpc_id
}

# Security group for traffic and network access for EC2 instances within our VPC
# TOO PERMISSIVE? MAY NEED TO FIX
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-ssh-sg"
  description = "Allow SSH"
  vpc_id      = data.aws_vpc.custom_vpc.id

  ingress {
    description      = "Allow all traffic between EC2 instances"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = [data.aws_vpc.custom_vpc.cidr_block] # open to all in VPC
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM role/policy/instance_profile to allow EC2 instances to communicate with ECS resources
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

### EC2 Instance Connect Endpoint Setup ###
# We want to allow ssh connection to private subnets on VPC
# This SG is attached to endpoints and controls outbound traffic from the endpoints
# This sg allows all outbound traffic so endpoints can initiate SSH tunnels to instances
resource "aws_security_group" "eic_endpoint_sg" {
  name   = "eic-endpoint-sg"
  vpc_id = data.aws_vpc.custom_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "eic-endpoint-sg" }
}

# One EC2 Instance Connect Endpoint for each private subnet is best practice for high availability
resource "aws_ec2_instance_connect_endpoint" "main" {
  for_each          = toset(var.private_subnet_ids)
  subnet_id         = each.value
  security_group_ids = [aws_security_group.eic_endpoint_sg.id]

  tags = { Name = "eic-endpoint-${each.value}" }
}

# Allow EC2 instances to receive SSH connections from EICE endpoints
# This rule enables port 22 inbound from the EICE endpoint SG to the ECS SG
# Ensures only EICE endpoints can SSH into EC2 instances, not the open internet
resource "aws_security_group_rule" "allow_ssh_from_eic" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.eic_endpoint_sg.id
}

resource "aws_iam_policy" "ecs_instance_connect_policy" {
  name        = "ecsInstanceConnectEndpointPolicy"
  description = "Restrict EC2 Instance Connect tunneling to specific IPs, port, and duration"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowEICTunnel",
        Effect = "Allow",
        Action = [
          "ec2-instance-connect:OpenTunnel",
          "ec2-instance-connect:SendSSHPublicKey"
        ],
        Resource = "*",
        Condition = {
          "StringEquals" = {
            "ec2-instance-connect:remotePort" = 22
          },
          "IpAddress" = {
            "ec2-instance-connect:privateIpAddress" = data.aws_vpc.custom_vpc.cidr_block
          },
          "NumericLessThanEquals" = {
            "ec2-instance-connect:maxTunnelDuration" = 3600
          }
        }
      },
      {
        Sid    = "AllowDescribeForEIC",
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceConnectEndpoints"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the instance connect policy to the role used for the EC2 instances
resource "aws_iam_role_policy_attachment" "ecs_instance_connect_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_instance_connect_policy.arn
}

# Create launch template so that EC2 machines can be created in the same way each time without manual intervention
# Fetch the latest Amazon Linux 2023 ECS-Optimized AMI (general-purpose, non-GPU)
data "aws_ssm_parameter" "ecs_al2023_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-lt-"
  image_id      = data.aws_ssm_parameter.ecs_al2023_ami.value
  instance_type = var.ec2_instance_type
  key_name      = "ecs-key"  # replace with your key pair
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  # Create an extra EBS volume for storing kafka log data
  # The volume is mounted to the EC2 instance at boot and to the location used for docker volumes
  # For our kafka cluster, we rely on node for data integrity and availability
  # Shared storage options would introduce too much latency, the EBS approach gives us some additional safety compared to general storage volumes which are temporary
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  # ECS optimized instances need ec2-instance-connect for EICE endpoint to work correctly
  user_data = base64encode(<<-EOT
              #!/bin/bash
              echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config

              # Update packages
              sudo dnf update -y

              # Install EC2 Instance Connect
              sudo dnf install -y ec2-instance-connect

              # mount extra ebs volume to the directory where docker creates volumes
              sudo mkfs -t xfs /dev/sdf
              sudo mount /dev/sdf /var/lib/docker/volumes

              # tell EC2 how to mount device at boot. Safe across restarts and renames.
              UUID=$(blkid -s UUID -o value /dev/sdf)

              # Update /etc/fstab if not already present
              if ! grep -q "$UUID" /etc/fstab; then
                  echo "UUID=$UUID /var/lib/docker/volumes xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab
              fi
              sudo systemctl restart docker
              EOT
  )
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "ecs-asg"
  max_size                  = var.ec2_instance_max
  min_size                  = var.ec2_instance_min
  desired_capacity          = var.ec2_instance_min
  vpc_zone_identifier       = var.private_subnet_ids # Replace with your subnet(s)
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

# Link Capacity Provider to ECS Cluster so that if we need more compute the cluster can automatically create the EC2 instances needed
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name       = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    weight            = 1
    base              = 1
  }
}

# Create a service discovery private dns namespace so services can create a resolvable dns on within the VPC
# Example: use ecs.local.kafka1 to reach a node instead of a static ip like 192.0.0.1:9092
resource "aws_service_discovery_private_dns_namespace" "ecs_private_dns_ns" {
  name        = "ecs.local"
  description = "Private namespace for ECS cluster"
  vpc         = data.aws_vpc.custom_vpc.id
}