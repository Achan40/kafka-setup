# Notes

Infrastructure is set up to have multiple "environments" on a single AWS account. You generally want separate AWS accounts with their own environments in reality, however, I'm working off AWS free tier and may have to restart after credits run out. This was the simplest approach to separate environments and following standard SDLC procedures.

* IMPORTANT: The remote backend s3 bucket that is created on the first `terragrunt apply` is not tracked in the terragrunt state. Will have to manually teardown if wiping infrastructure completely.
* IMPORTANT: OIDC Provider and associated role/policies needed for github actions (CI/CD) requires one time provisioning. The directory `infra/live/bootstrap` contains the setup.

### Quick Notes
* Terragrunt commands:
    * `terragrunt hcl fmt` format terragrunt files to be more readable
    * `terragrunt plan --all` validate resource declaration
    * `terragrunt apply --all` provision all resources listed in a certain directory. Used when organized in modules.
    * `terragrunt destroy --all` teardown resources

