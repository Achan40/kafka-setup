# kafka-setup
Setting up a kafka system on AWS.

## Infrastructure Setup
Use terraform to provision AWS services.
1. Follow the first few steps of the [terraform setup](https://spacelift.io/blog/terraform-tutorial) docs to install and allow terraform to access AWS
2. From project root, `cd terraform/bootstrap`
3. Create the OIDC provider and role `terraform apply` 
4. Copy the role arn from the output and store the in github environment variable `CI_CD_ROLE_ARN`, this will allow the CI/CD pipeline to run on push to main
5. Navigate to the core infrastructure directory `cd terraform/core`
6. Run `terraform apply` to create the remaining infrastructure