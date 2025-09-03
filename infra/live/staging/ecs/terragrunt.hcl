include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../modules/ecs"
}

inputs = {
  ecs_cluster_name = "ecs-kafka-setup-staging"
  project_tag      = "kafka-setup-staging"
}