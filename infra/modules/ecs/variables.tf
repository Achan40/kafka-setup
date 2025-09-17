variable "project_tag" {
  type = string
  description = "Project tag"
}

variable "ecs_cluster_name" {
  type = string
  description = "Name of ecs cluster"
}

variable "aws_region" {
  type = string
  description = "Name of instance region"
}

variable "ec2_instance_min" {
  type = number
  description = "Num of instances minimum"
}

variable "ec2_instance_max" {
  type = number
  description = "Num of instances maximum"
}