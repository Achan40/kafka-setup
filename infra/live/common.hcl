remote_state {
  backend = "s3"
  config = {
    bucket                 = "kafka-setup-terraform-state-bucket"
    region                 = "us-east-2"
    encrypt                = true
    key                    = "${path_relative_to_include()}/terraform.tfstate"
    use_lockfile           = true
    skip_bucket_versioning = false
  }
}