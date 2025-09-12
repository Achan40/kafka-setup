output "ecr_repository_url" {
  description = "kafka-setup EBS repository URL"
  value       = aws_ecr_repository.kafka_setup_repo.repository_url
}