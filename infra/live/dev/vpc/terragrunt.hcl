include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  name                = "kafka-setup"
  region              = "us-east-2"
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-east-2a", "us-east-2b"]
}