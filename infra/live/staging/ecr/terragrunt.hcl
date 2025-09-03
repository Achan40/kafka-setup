include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../modules/ecr"
}

inputs = {
  ecr_repo_name = "ecr-kafka-setup-staging"
  project_tag   = "kafka-setup-staging"
}