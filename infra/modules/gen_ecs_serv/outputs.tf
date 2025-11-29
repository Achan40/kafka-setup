output "task_definition_arn" {
  description = "ARN of the task definition"
  value = aws_ecs_task_definition.task.arn
}

output "service_arn" {
  description = "ARN of the ECS service"
  value = aws_ecs_service.service.arn
}