# Overview
Terraform/terragrunt is used to provision AWS resources.

The main purpose here is to set up a small-scale, production ready kafka cluster on a single region with multiple availability zones. Additional features include kafka-connect and kafbat for cluster monitoring. 

## Modules
For module documentation, README.md files are available within each sub-directory of the parent `infra/modules`. Generated using `terraform-docs`. 

For module usage examples, see each sub-directory of the parent `infra/live`.

## Modules Description

### ecr
Provisions an ECR repository to store container images.

### vpc
Sets up a custom vpc for our resources. Support for multiple az exists, if more than one az is defined, a public and private subnet is created for each on.
* Services should be attached to the private subnet(s).
* The private subnet(s) are linked to NAT gateway(s) which allows private subnet outbound traffic. An internet gateway is created which allows for the public subnet to access traffic to and from the internet, NAT(s) will filter traffic so that only inbound traffic, connections to private instances, are blocked.
* EC2 instances attached to the VPC and on private subnets can access the internet without exposing themselves. 

Since our core services are on private subnets, if we want to acces them we need to establish a VPN connection to our VPC.
1. Generate Certificates Locally
```
# Clone AWS example certs repo
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3

# Initialize PKI
./easyrsa init-pki

# Build CA (you’ll be prompted for a common name)
./easyrsa build-ca nopass

# Build server cert
./easyrsa --san=DNS:kafka build-server-full server nopass

# Build one client cert
./easyrsa --san=DNS:kafka build-client-full client1 nopass
```
2. Import Certificates into AWS ACM
```
# Server cert (for the VPN endpoint)
aws acm import-certificate \
  --certificate fileb://pki/issued/server.crt \
  --private-key fileb://pki/private/server.key \
  --certificate-chain fileb://pki/ca.crt

# Client cert
aws acm import-certificate \
  --certificate fileb://pki/issued/client1.crt \
  --private-key fileb://pki/private/client1.key \
  --certificate-chain fileb://pki/ca.crt
```
3. Export and connect (after VPC resource created)
```
aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id <endpoint-id> \
  --output text > client.ovpn
```
4. Open VPN client, import `client.ovpn`, replace the cert placeholders in the file with your local cert paths (client1.crt, client1.key, ca.crt) and connect through your vpn client.

### ecs
Provisions an ECS cluster to run containers. Utilizes EC2 infrastructure. 
* Creates a launch template for EC2 infra. Maps EBS volumes to docker volumes locations for persistence, as well as other EC2 start up tasks.
* Configures autoscaling group and capacity providers.
* Enables EC2 instance connect endpoint for web-SSH access to EC2 on private subnets.
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

## Environments
Infrastructure is set up to have multiple "environments" on a single AWS account. You generally want separate AWS accounts for each environments in production, however, I'm working off AWS free tier and may have to restart after credits run out. This was the simplest approach to separate environments and following standard SDLC procedures.

* IMPORTANT: The remote backend s3 bucket that is created on the first `terragrunt apply` is not tracked in the terragrunt state. Will have to manually teardown if wiping infrastructure completely.
* IMPORTANT: OIDC Provider and associated role/policies needed for github actions CI/CD requires one time provisioning. The directory `infra/live/bootstrap` contains the setup.

## Quick Notes
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
