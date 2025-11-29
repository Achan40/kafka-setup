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
| [aws_cloudwatch_log_group.kafka](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/ecs_task_definition) | resource |
| [aws_service_discovery_service.broker](https://registry.terraform.io/providers/hashicorp/aws/6.10.0/docs/resources/service_discovery_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where the ECS task will be deployed. | `string` | n/a | yes |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | The ARN of the ECS cluster where the service will be deployed. | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | container name | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of ECS tasks that should be running for the service. For kafka nodes, one task per service is optimal. May run into issue if more than one task is created for each service. | `number` | `1` | no |
| <a name="input_ecs_capacity_provider_name"></a> [ecs\_capacity\_provider\_name](#input\_ecs\_capacity\_provider\_name) | capacity provider name. Link to service so that it can scale up as needed. | `string` | n/a | yes |
| <a name="input_ecs_cluster_sg"></a> [ecs\_cluster\_sg](#input\_ecs\_cluster\_sg) | Security group for ECS cluster | `string` | n/a | yes |
| <a name="input_ecs_cluster_subnet_ids"></a> [ecs\_cluster\_subnet\_ids](#input\_ecs\_cluster\_subnet\_ids) | ECS cluster subnet id | `list(string)` | n/a | yes |
| <a name="input_ecs_cluster_vpc_id"></a> [ecs\_cluster\_vpc\_id](#input\_ecs\_cluster\_vpc\_id) | VPC id for ECS cluster | `string` | n/a | yes |
| <a name="input_ecs_private_dns_ns"></a> [ecs\_private\_dns\_ns](#input\_ecs\_private\_dns\_ns) | DNS namespace for ECS cluster | `string` | n/a | yes |
| <a name="input_kafka_advertised_listeners"></a> [kafka\_advertised\_listeners](#input\_kafka\_advertised\_listeners) | Kafka advertised listeners | `string` | n/a | yes |
| <a name="input_kafka_controller_listener_names"></a> [kafka\_controller\_listener\_names](#input\_kafka\_controller\_listener\_names) | Kafka controller listener names | `string` | `"CONTROLLER"` | no |
| <a name="input_kafka_controller_quorum_voters"></a> [kafka\_controller\_quorum\_voters](#input\_kafka\_controller\_quorum\_voters) | Kafka controller quorum voters mapping (nodeId@host:port) | `string` | n/a | yes |
| <a name="input_kafka_inter_broker_listener_name"></a> [kafka\_inter\_broker\_listener\_name](#input\_kafka\_inter\_broker\_listener\_name) | Kafka inter-broker listener name | `string` | `"INTERNAL"` | no |
| <a name="input_kafka_listener_security_protocol_map"></a> [kafka\_listener\_security\_protocol\_map](#input\_kafka\_listener\_security\_protocol\_map) | Mapping of listener names to security protocols | `string` | `"INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT"` | no |
| <a name="input_kafka_listeners"></a> [kafka\_listeners](#input\_kafka\_listeners) | Kafka listener bindings | `string` | `"INTERNAL://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,EXTERNAL://0.0.0.0:29092"` | no |
| <a name="input_kafka_node_id"></a> [kafka\_node\_id](#input\_kafka\_node\_id) | Unique Kafka node ID | `string` | n/a | yes |
| <a name="input_kafka_offsets_topic_replication_factor"></a> [kafka\_offsets\_topic\_replication\_factor](#input\_kafka\_offsets\_topic\_replication\_factor) | Kafka offsets topic replication factor. Set equal to the number of nodes you are running, otherwise reading from topics will fail. | `string` | `"1"` | no |
| <a name="input_kafka_process_roles"></a> [kafka\_process\_roles](#input\_kafka\_process\_roles) | Kafka process roles | `string` | `"broker,controller"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The name of the ECS service to create or manage. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the task definition |
<!-- END_TF_DOCS -->