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
  ec2_instance_max  = 2
  ec2_instance_type = "c7i-flex.large"
}

/* AWS CLI command to find eligible instance types for free tier
aws ec2 describe-instance-types \
    --filters "Name=free-tier-eligible,Values=true" \
    --query "InstanceTypes[].{Type: InstanceType, vCPUs: VCpuInfo.DefaultVCpus, Memory: MemoryInfo.SizeInMiB}" \
    --output table
*/