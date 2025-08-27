# kafka-setup
Setting up a kafka system on AWS using ECS and github actions with continuous deployment.

## Process
1. terraform
    * terraform setup with AWS https://spacelift.io/blog/terraform-tutorial
    * create IAM user with administrator policy, create access key and secret access key
    * commands: 
        `terraform fmt` format terraform files to be more readable
        `terraform plan` validate resource declaration
        `terraform apply` provision resources
        `terraform destroy` teardown resources

1. AWS
    * ECS cluster should be already created 
    * ECS service should be created (with EC2 or fargate service)
    * ECR repository should be created
    * Create IAM user with ECR/ECS permissions. Create group, attach policies, add user to group. 
        * Policies: 

2. Github Actions
    * Set up secrets
    •	AWS_ACCESS_KEY_ID → IAM user’s access key with ECR/ECS permissions.
	•	AWS_SECRET_ACCESS_KEY → IAM user’s secret key.
	•	AWS_REGION → your AWS region (e.g., us-east-1).
	•	ECR_REPOSITORY → your ECR repo name (e.g., hello-world-app).
	•	ECS_CLUSTER → your ECS cluster name.
	•	ECS_SERVICE → your ECS service name.