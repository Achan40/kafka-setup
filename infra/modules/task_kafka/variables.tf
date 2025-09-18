variable "container_name" {
  type = string
  description = "container name"
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the ECS task will be deployed."
}

variable "service_name" {
  type        = string
  description = "The name of the ECS service to create or manage."
}

variable "cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster where the service will be deployed."
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "The number of ECS tasks that should be running for the service."
}

variable "ecs_cluster_subnet_ids" {
  type = list(string)
  description = "ECS cluster subnet id"
}

variable "ecs_cluster_sg" {
  description = "Security group for ECS cluster"
}

variable "ecs_cluster_vpc_id" {
  description = "VPC id for ECS cluster"
}