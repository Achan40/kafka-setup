# kafka-setup
Setting up a kafka system on AWS.

## Infrastructure Setup
Use terragrunt to provision AWS services.
1. Follow the first few steps of the [terraform setup](https://spacelift.io/blog/terraform-tutorial) docs to install and allow terraform to access AWS
2. Install [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/quick-start)
3. From project root, navigate to prod `cd infa/prod`
4. Run `terragrunt apply --backend-bootstrap`. Subsequent runs will only need `terragrunt apply`, --backend-bootstrap is required one time to create the s3 bucket to store terraform state remotely.
5. Copy the role arn from the output and store the in github environment variable `CI_CD_ROLE_ARN`, this will allow the CI/CD pipeline to run on push to main