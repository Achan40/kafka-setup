output "ecr_repository_url" {
  description = "kafka-setup EBS repository URL"
  value       = aws_ecr_repository.kafka_setup_repo.repository_url
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS kafka-setup-cluster"
  value       = aws_ecs_cluster.kafka_setup_cluster.arn
}

output "ci_cd_ecs_ecr_role_arn" {
  description = "ARN of the CI/CD role for github"
  value       = aws_iam_role.ci_cd_role.arn
}