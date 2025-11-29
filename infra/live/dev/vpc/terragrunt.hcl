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
  availability_zones  = ["us-east-2a","us-east-2b"]
  client_cidr_block   = "10.20.0.0/16"
  server_cert_arn     = "arn:aws:acm:us-east-2:084719917325:certificate/da7a13cb-b45e-47bd-8102-593a5056f36a"
}