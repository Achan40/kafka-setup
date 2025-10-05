# Infrastructure Design
Terraform/terragrunt is used to provision AWS resources. Services used include but are not limited to: ECS, ECR, EC2, S3, RDS

The main purpose here is to set up a small-scale, production, ready kafka cluster. Features: multi-node kafka setup, Kafka-connect, cluster monitoring with kafbat, automatic container image deployment to ECR.

# Modules
### ecr
Provisions an ECR repository to store container images.
### ecs
Provisions an ECS cluster to run containers. Utilizes EC2 infrastructure. 
* Creates a launch template for EC2 infra. Maps EBS volumes to docker volumes locations for persistence, as well as other EC2 start up tasks.
* Configures autoscaling group and capacity providers.
* Enables EC2 instance connect for web-SSH access to machines.
* Most of our networking is set up here to allow traffic in/out of EC2 instances. 
* Also sets up a private dns namespace so our services can create a resolvable dns within the VPC.

### gen_ecs_serv
Creates a generic ECS service that runs a container. Deploys to an existing ECS cluster and utilizes its EC2 resources. 
### kafka_ecs_serv
Creates a single node kafka ECS service. Deploys to an existing ECS cluster. 
* This is meant to be a single service and task, don't want to run into any issues with idempotence.
* EBS volumes are used for kafka log data persistence in case the service goes down as allows better persistence as opposed to regular bind mounts. Shared cloud storage like EFS would introduce too much latency, we instead rely on replications to maintain data integrity throughout the cluster.
* Multiple nodes can be created by re-using the module, but configs for each need to be updated as well to support additional nodes. 
* Requires a private dns namespace (one is created in the ecs module above). This allows traffic within a VPC to reach the kafka cluster by utilizing a its service discovery endpoint.
### oidc
Provisions oidc provider for a specific github repository. Sets up IAM role, attaches policy with permissions to it. The ARN can then be used for authentication for github actions. 


# Additional Info
Infrastructure is set up to have multiple "environments" on a single AWS account. You generally want separate AWS accounts for each environments in production, however, I'm working off AWS free tier and may have to restart after credits run out. This was the simplest approach to separate environments and following standard SDLC procedures.

* IMPORTANT: The remote backend s3 bucket that is created on the first `terragrunt apply` is not tracked in the terragrunt state. Will have to manually teardown if wiping infrastructure completely.
* IMPORTANT: OIDC Provider and associated role/policies needed for github actions CI/CD requires one time provisioning. The directory `infra/live/bootstrap` contains the setup.



# Quick Notes
* Terragrunt commands:
    * `terragrunt hcl fmt` format terragrunt files to be more readable
    * `terragrunt plan --all` validate resource declaration
    * `terragrunt apply --all` provision all resources listed in a certain directory. Used when organized in modules.
    * `terragrunt destroy --all` teardown resources

* Docker commands:
    * `docker ps` list running containers
    * `docker exec -it <container_id> /bin/bash` enter container

* Kafka commands:
    * `/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server kafka1.ecs.local:9092` 
    * `/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server kafka1.ecs.local:9092 --topic test-topic`
    * `/opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka1.ecs.local:9092 --list`
    * `/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka1.ecs.local:9092 --topic test-topic --from-beginning`
    * `/opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server kafka1.ecs.local:9092 --describe --all-groups`