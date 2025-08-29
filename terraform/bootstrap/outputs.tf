output "ci_cd_ecs_ecr_role_arn" {
  description = "ARN of the CI/CD role for github"
  value       = aws_iam_role.ci_cd_role.arn
}

output "tf_state_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}