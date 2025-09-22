include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../modules/kafka_ecs_serv"
}

dependency "ecs" {
  config_path = "../ecs" # path to your ECS cluster Terragrunt config
}

inputs = {
  cluster_arn    = dependency.ecs.outputs.ecs_cluster_arn
  ecs_cluster_sg = dependency.ecs.outputs.ecs_cluster_sg
  ecs_cluster_subnet_ids = dependency.ecs.outputs.ecs_cluster_subnet_ids
  ecs_cluster_vpc_id = dependency.ecs.outputs.ecs_cluster_vpc_id
  container_name = "kafka-1"
  service_name   = "kafka-service"
  aws_region     = "us-east-2"
  desired_count  = 1
}