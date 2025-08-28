resource "aws_ecr_repository" "kafka_setup_repo" {
  name                 = "kafka-setup-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = local.project_tag
  }
}

resource "aws_ecs_cluster" "kafka_setup_cluster" {
  name = "kafka-setup-cluster"
  tags = {
    Name = local.project_tag
  }
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "ci_cd_role" {
  name = "ci-cd-ecs-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Allow any branch in the repo
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ci_cd_policy" {
  name        = "ci-cd-ecs-ecr-policy"
  description = "Policy for GitHub Actions to provision ECS and ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:*",
          "ecr:*",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_cd_attach" {
  role       = aws_iam_role.ci_cd_role.name
  policy_arn = aws_iam_policy.ci_cd_policy.arn
}