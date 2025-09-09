terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }
  backend "s3" {
  }
}

####### OIDC Provider, role, and policy for github actions ##########
# set up oidc provider
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# set up iam role for github actions to use
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
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })
}

# set up policy to get iam role permissions to use certain aws services
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
          "s3:*"
        ]
        Resource = "*"
      },

      # EC2 provisioning (instances, networking, SGs, AMIs, etc.)
      {
        Effect   = "Allow"
        Action   = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*"
        ]
        Resource = "*"
      },

      # IAM role pass-through (needed when attaching IAM roles to EC2/ECS tasks)
      {
        Effect   = "Allow"
        Action   = [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:PassRole",
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:UpdateAssumeRolePolicy" 
        ]
        Resource = "*"
      },
      # SSM
      {
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/aws/service/ecs/optimized-ami/*"
      }
    ]
  })
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "ci_cd_attach" {
  role       = aws_iam_role.ci_cd_role.name
  policy_arn = aws_iam_policy.ci_cd_policy.arn
}