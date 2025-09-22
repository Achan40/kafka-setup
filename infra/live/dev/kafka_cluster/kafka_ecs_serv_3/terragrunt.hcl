include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../../modules/kafka_ecs_serv"
}

dependency "ecs" {
  config_path = "../../ecs" # path to your ECS cluster Terragrunt config
}

inputs = {
  cluster_arn    = dependency.ecs.outputs.ecs_cluster_arn
  ecs_cluster_sg = dependency.ecs.outputs.ecs_cluster_sg
  ecs_cluster_subnet_ids = dependency.ecs.outputs.ecs_cluster_subnet_ids
  ecs_cluster_vpc_id = dependency.ecs.outputs.ecs_cluster_vpc_id
  ecs_private_dns_ns = dependency.ecs.outputs.ecs_private_dns_ns
  ecs_capacity_provider_name = dependency.ecs.outputs.ecs_capacity_provider_name
  container_name = "kafka3"
  service_name   = "kafka-service3"
  aws_region     = "us-east-2"
  desired_count  = 1 # with stateful kafka service, best to set desired tasks to 1

  # DNS address is a combination of container_name and ecs_private_dns_ns_name
  kafka_node_id                        = "3"
  kafka_process_roles                  = "broker,controller"
  kafka_controller_quorum_voters       = "1@kafka1.${dependency.ecs.outputs.ecs_private_dns_ns_name}:9093,2@kafka2.${dependency.ecs.outputs.ecs_private_dns_ns_name}:9093,3@kafka3.${dependency.ecs.outputs.ecs_private_dns_ns_name}:9093"
  kafka_listeners                      = "INTERNAL://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,EXTERNAL://0.0.0.0:29092"
  kafka_advertised_listeners           = "INTERNAL://kafka3.${dependency.ecs.outputs.ecs_private_dns_ns_name}:9092,EXTERNAL://kafka3.${dependency.ecs.outputs.ecs_private_dns_ns_name}:29092"
  kafka_listener_security_protocol_map = "INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT"
  kafka_inter_broker_listener_name     = "INTERNAL"
  kafka_controller_listener_names      = "CONTROLLER"
  kafka_offsets_topic_replication_factor = "3"  # Should equal to number of kafka nodes. Otherwise issues with consuming data from topic WILL occur.
}