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
| [aws_autoscaling_group.ecs_asg](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/autoscaling_group) | resource |
| [aws_ec2_instance_connect_endpoint.main](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ec2_instance_connect_endpoint) | resource |
| [aws_ecs_capacity_provider.ecs_cp](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.kafka_setup_cluster](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.ecs_cluster_cp](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_instance_profile.ecs_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ecs_instance_connect_policy](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_connect_attach](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_role_attach](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.ecs_lt](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/launch_template) | resource |
| [aws_security_group.ecs_sg](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/security_group) | resource |
| [aws_security_group.eic_endpoint_sg](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_ssh_from_eic](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_private_dns_namespace.ecs_private_dns_ns](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_ssm_parameter.ecs_al2023_ami](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/data-sources/ssm_parameter) | data source |
| [aws_vpc.custom_vpc](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_instance_max"></a> [ec2\_instance\_max](#input\_ec2\_instance\_max) | Maximum number of EC2 instances | `number` | n/a | yes |
| <a name="input_ec2_instance_min"></a> [ec2\_instance\_min](#input\_ec2\_instance\_min) | Minimum number of EC2 instances | `number` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Type of EC2 instance | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster to create | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnets ids within the VPC | `list(string)` | n/a | yes |
| <a name="input_project_tag"></a> [project\_tag](#input\_project\_tag) | Specify a tag for the group of services | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | id of some existing VPC to launch the ECS cluster within | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_capacity_provider_name"></a> [ecs\_capacity\_provider\_name](#output\_ecs\_capacity\_provider\_name) | Capacity provider name, that is linked to an autoscaling group |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_ecs_cluster_sg"></a> [ecs\_cluster\_sg](#output\_ecs\_cluster\_sg) | Security group for ECS cluster |
| <a name="output_ecs_cluster_subnet_ids"></a> [ecs\_cluster\_subnet\_ids](#output\_ecs\_cluster\_subnet\_ids) | Subnet ids for ECS cluster |
| <a name="output_ecs_cluster_vpc_id"></a> [ecs\_cluster\_vpc\_id](#output\_ecs\_cluster\_vpc\_id) | VPC id used for ECS cluster |
| <a name="output_ecs_private_dns_ns"></a> [ecs\_private\_dns\_ns](#output\_ecs\_private\_dns\_ns) | DNS namespace id |
| <a name="output_ecs_private_dns_ns_name"></a> [ecs\_private\_dns\_ns\_name](#output\_ecs\_private\_dns\_ns\_name) | DNS namespace name |
<!-- END_TF_DOCS -->