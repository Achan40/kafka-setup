### Notes
* Terraform commands:
    * `terraform fmt` format terraform files to be more readable
    * `terraform plan` validate resource declaration
    * `terraform apply` provision resources
    * `terraform destroy` teardown resources
* This project relies on two terraform projects
    * **bootstrap** - one time usage to provision resources that must be created prior to others. For example: OIDC provider (credential free GitHub actions), s3 bucket (for tracking terraform state remotely). Since these resources are tracked locally, may be hard to teardown if needed. Note to self: add these  
    * **actual** - main resources, can be updated quite easily due to the CI/CD pipeline. State tracked remotely.
