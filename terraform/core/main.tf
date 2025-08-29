# set up ECR repo for storing images
resource "aws_ecr_repository" "kafka_setup_repo" {
  name                 = "kafka-setup-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = local.project_tag
  }
}

# set up ECS cluster for serving containers
resource "aws_ecs_cluster" "kafka_setup_cluster" {
  name = "kafka-setup-cluster"
  tags = {
    Name = local.project_tag
  }
}


###### Define backend resource