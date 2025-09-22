output "task_definition_arn" {
  value = aws_ecs_task_definition.task.arn
}

output "service_arn" {
  value = aws_ecs_service.service.arn
}