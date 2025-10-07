# kafka-setup
Setting up a kafka system on AWS.

## Infrastructure Setup
Use terragrunt to provision AWS services.
1. Follow the first few steps of the [terraform setup](https://spacelift.io/blog/terraform-tutorial) docs to install and allow terraform to access AWS
2. Install [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/quick-start)
3. From project root, navigate to dev `cd infa/live/dev`
4. Run `terragrunt apply --all --backend-bootstrap`
5. Subsequent runs will only need `terragrunt apply --all`, --backend-bootstrap is required one time to create the s3 bucket to store terraform state remotely. 
Note: when starting from scratch just deploy main services like ECR and ECS. ECS services will require a container image stored on ECR to boot correctly.

-- (optional) Create OIDC provider --
1. From project root, navigate to bootstrap directory `cd infa/live/bootstrap`
2. Run `terragrunt apply`
3. Copy the role arn from the output and store in github environment variable `CI_CD_ROLE_ARN`, this will set up the credentials for Github actions to run workflows.

-- (optional) EC2 ssh access --
1. create ssh key locally
``` 
aws ec2 create-key-pair \
--key-name ecs-key \
--query 'KeyMaterial' \
--output text > ecs-key.pem 
```
2. Set permissions for the key `chmod 400 ecs-key.pem`
3. Use the key in terraform `key_name = "ecs-key"`
4. Access EC2 instance `ssh -i ecs-key.pem ec2-user@<EC2_PUBLIC_IP>`