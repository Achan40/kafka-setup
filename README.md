# kafka-setup
Setting up a kafka system on AWS.

## Infrastructure Setup
Use terragrunt to provision AWS services.
1. Follow the first few steps of the [terraform setup](https://spacelift.io/blog/terraform-tutorial) docs to install and allow terraform to access AWS
2. Install [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/quick-start)
3. From project root, navigate to dev `cd infa/live/dev`
4. Run `terragrunt apply --all --backend-bootstrap`
5. Subsequent runs will only need `terragrunt apply --all`, --backend-bootstrap is required one time to create the s3 bucket to store terraform state remotely.

-- (optional) Create OIDC provider --
1. From project root, navigate to bootstrap directory `cd infa/live/bootstrap`
2. Run `terragrunt apply --all`
3. Copy the role arn from the output and store in github environment variable `CI_CD_ROLE_ARN`, this will set up the credentials for Github actions to run workflows.