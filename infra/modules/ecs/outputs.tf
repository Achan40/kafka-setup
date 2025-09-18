output "ecs_cluster_arn" {
  description = "ARN of the ECS kafka-setup-cluster"
  value       = aws_ecs_cluster.kafka_setup_cluster.arn
}

output "ecs_cluster_subnet_ids" {
  description = "Subnet ids for ECS cluster"
  value =  data.aws_subnets.default.ids
}

output "ecs_cluster_sg" {
  description = "Security group for ECS cluster"
  value = aws_security_group.ecs_sg.id
}

output "ecs_cluster_vpc_id" {
  description = "VPC id used for ECS cluster"
  value = data.aws_vpc.default.id
}