# kafka-setup
Infrastructure setup for a multi-node Kafka system utilizing various AWS services. Services include but are not limited to: ECS, ECR, EC2, EBS, VPC. 

## Usage
Terragrunt/terraform is used to provision AWS services. 
1. Follow the first few steps of the [terraform setup](https://spacelift.io/blog/terraform-tutorial) docs to install and allow terraform to access AWS
2. Install [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/quick-start)
3. From project root, navigate to directory for the desired environment, example: `cd infa/live/dev`
4. Run `terragrunt apply --all --backend-bootstrap`. `--backend-bootstrap` is required one time to create the s3 bucket to store terraform state remotely. 

### Optional: Create OIDC provider
1. From project root, navigate to bootstrap directory `cd infa/live/bootstrap`
2. Run `terragrunt apply`
3. Copy the role arn from the output and store in github environment variable `CI_CD_ROLE_ARN`, this will set up the credentials needed for Github actions to run workflows.

## Contributing
PRs welcome. Please follow these steps:

1. Fork the repo.
2. Create a feature branch (`git checkout -b feat/your-feature`).
3. Commit your changes.
4. Push to your branch (`git push origin feat/your-feature`).
5. Open a PR.

## License

TBD

## Contact

- GitHub: [@Achan40](https://github.com/Achan40)
- Email: chanman2841@gmail.com
- LinkedIn: https://www.linkedin.com/in/aaron-chan-30393115a/

## Credits
TBD