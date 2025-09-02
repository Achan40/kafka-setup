output "ci_cd_ecs_ecr_role_arn" {
  description = "ARN of the CI/CD role for github"
  value       = aws_iam_role.ci_cd_role.arn
}