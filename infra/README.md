### Notes
* Terragrunt commands:
    * `terragrunt run -- fmt` format terragrunt files to be more readable
    * `terragrunt plan` validate resource declaration
    * `terragrunt apply` provision resources
    * `terragrunt destroy` teardown resources
* IMPORTANT: The remote backend s3 bucket that is created on the first `terragrunt apply` is not tracked in the terragrunt state. Will have to manually teardown if wiping infrastructure completely.