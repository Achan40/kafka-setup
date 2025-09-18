include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../modules/ecs"
}

inputs = {
  ecs_cluster_name  = "ecs-kafka-setup-dev"
  project_tag       = "kafka-setup-dev"
  aws_region        = "us-east-2"
  ec2_instance_min  = 2
  ec2_instance_max  = 3
  ec2_instance_type = "t3.small"
}