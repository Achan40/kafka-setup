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
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ecs_task_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | The ARN of the ECS cluster where the service will be deployed. | `string` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The Docker image to use for the container, including the ECR or Docker registry path and tag. | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the container in the task definition. | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container listens on. Used for port mappings in the ECS task definition. | `number` | `80` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The size of EC2 cpu needed for the container in 1/1000 of vcpu | `string` | `"256"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of ECS tasks that should be running for the service. | `number` | `1` | no |
| <a name="input_family"></a> [family](#input\_family) | The family name for the ECS task definition. Think of it as a group identifier for versions of this task. | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The size of EC2 memory needed for the container in mb | `string` | `"512"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The name of the ECS service to create or manage. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | ARN of the ECS service |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the task definition |
<!-- END_TF_DOCS -->