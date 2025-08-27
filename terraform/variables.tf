locals {
    project_tag = "kafka-setup"
}

variable "github_repo" {
  description = "GitHub repo in the format owner/repo"
  default        = "Achan40/kafka-setup"
}

variable "github_branch" {
  description = "Branch name allowed to assume this role"
  default     = "main"
}