variable "cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster where the service will be deployed."
}

variable "ecs_cluster_sg" {
  type = string
  description = "Security group for ECS cluster"
}

variable "ecs_cluster_subnet_ids" {
  type = list(string)
  description = "ECS cluster subnet id"
}

variable "ecs_cluster_vpc_id" {
  type = string
  description = "VPC id for ECS cluster"
}

variable "ecs_private_dns_ns" {
  type = string
  description = "DNS namespace for ECS cluster"
}

variable "container_name" {
  type = string
  description = "container name"
}

variable "service_name" {
  type        = string
  description = "The name of the ECS service to create or manage."
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the ECS task will be deployed."
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "The number of ECS tasks that should be running for the service."
}

variable "kafka_node_id" {
  description = "Unique Kafka node ID"
  type        = string
}

variable "kafka_process_roles" {
  description = "Kafka process roles"
  type        = string
  default     = "broker,controller"
}

variable "kafka_controller_quorum_voters" {
  description = "Kafka controller quorum voters mapping (nodeId@host:port)"
  type        = string
}

variable "kafka_listeners" {
  description = "Kafka listener bindings"
  type        = string
  default     = "INTERNAL://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,EXTERNAL://0.0.0.0:29092"
}

variable "kafka_advertised_listeners" {
  description = "Kafka advertised listeners"
  type        = string
}

variable "kafka_listener_security_protocol_map" {
  description = "Mapping of listener names to security protocols"
  type        = string
  default     = "INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT"
}

variable "kafka_inter_broker_listener_name" {
  description = "Kafka inter-broker listener name"
  type        = string
  default     = "INTERNAL"
}

variable "kafka_controller_listener_names" {
  description = "Kafka controller listener names"
  type        = string
  default     = "CONTROLLER"
}

variable "kafka_offsets_topic_replication_factor" {
  description = "Kafka offsets topic replication factor"
  type        = string
  default     = "1" # set to 1 for single node, otherwise equal to number of Kafka nodes
}

variable "ecs_capacity_provider_name" {
  description = "capacity provider name. link to service so that it can scale up"
  type = string
}