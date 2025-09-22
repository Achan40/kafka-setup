variable "family" {
  type        = string
  description = "The family name for the ECS task definition. Think of it as a group identifier for versions of this task."
}

variable "container_name" {
  type        = string
  description = "The name of the container in the task definition."
}

variable "container_image" {
  type        = string
  description = "The Docker image to use for the container, including the ECR or Docker registry path and tag."
}

variable "container_port" {
  type        = number
  default     = 80
  description = "The port the container listens on. Used for port mappings in the ECS task definition."
}

variable "service_name" {
  type        = string
  description = "The name of the ECS service to create or manage."
}

variable "cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster where the service will be deployed."
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "The number of ECS tasks that should be running for the service."
}

variable "cpu" {
  type = string
  description = "The size of EC2 cpu needed for the container in 1/1000 of vcpu"
  default = "256"
}

variable "memory" {
  type = string
  description = "The size of EC2 memory needed for the container in mb"
  default = "512"
}