locals {
  project_tag = "kafka-setup"
}

variable "github_repo" {
  description = "GitHub repo in the format owner/repo"
  default     = "Achan40/kafka-setup"
}