include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../modules/ecs"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  ecs_cluster_name  = "ecs-kafka-setup-dev"
  project_tag       = "kafka-setup-dev"
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  client_cidr_block = dependency.vpc.outputs.client_cidr_block
  ec2_instance_min  = 2
  ec2_instance_max  = 2
  ec2_instance_type = "c7i-flex.large"
}

/* AWS CLI command to find eligible instance types for free tier
aws ec2 describe-instance-types \
    --filters "Name=free-tier-eligible,Values=true" \
    --query "InstanceTypes[].{Type: InstanceType, vCPUs: VCpuInfo.DefaultVCpus, Memory: MemoryInfo.SizeInMiB}" \
    --output table
*/