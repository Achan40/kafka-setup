variable "project_tag" {
  type = string
  description = "Project tag"
}

variable "ecs_cluster_name" {
  type = string
  description = "Name of ECS cluster"
}

variable "vpc_id" {
  type = string
  description = "id of some VPC"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "List of private subnets ids within the VPC"
}

variable "ec2_instance_min" {
  type = number
  description = "Minimum number of EC2 instances"
}

variable "ec2_instance_max" {
  type = number
  description = "Maximum number of EC2 instances"
}

variable "ec2_instance_type" {
  type = string
  description = "Type of EC2 instance"
}