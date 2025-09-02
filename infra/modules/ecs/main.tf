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