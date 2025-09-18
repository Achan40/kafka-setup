include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../modules/task_serv_1"
}

dependency "ecs" {
  config_path = "../ecs" # path to your ECS cluster Terragrunt config
}

inputs = {
  family          = "hello-world"
  cluster_arn     = dependency.ecs.outputs.ecs_cluster_arn
  container_name  = "hello-world"
  container_image = "084719917325.dkr.ecr.us-east-2.amazonaws.com/ecr-kafka-setup-dev:hello_world-latest"
  container_port  = 8080
  service_name    = "hello-world-service"
  desired_count   = 1
  cpu             = "256"
  memory          = "512"
}