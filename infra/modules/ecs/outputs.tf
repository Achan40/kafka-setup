output "ecs_cluster_arn" {
  description = "ARN of the ECS kafka-setup-cluster"
  value       = aws_ecs_cluster.kafka_setup_cluster.arn
}