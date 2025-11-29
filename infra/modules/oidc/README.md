<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github_oidc](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.ci_cd_policy](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.ci_cd_role](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ci_cd_attach](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | Github Repository name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ci_cd_ecs_ecr_role_arn"></a> [ci\_cd\_ecs\_ecr\_role\_arn](#output\_ci\_cd\_ecs\_ecr\_role\_arn) | ARN of the CI/CD role for github |
<!-- END_TF_DOCS -->