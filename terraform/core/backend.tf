terraform {
    backend "s3" {
    bucket         = "kafka-setup-terraform-state-bucket"
    key            = "kafka-setup/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile = true
    encrypt        = true
  }
}
