variable "project_tag" {
  type = string
  description = "Project tag"
}

variable "ecs_cluster_name" {
  type = string
  description = "Name of ecs cluster"
}

variable "vpc_id" {
  type = string
  description = "id of a custom vpc"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "list of private subnets ids"
}

variable "ec2_instance_min" {
  type = number
  description = "Num of instances minimum"
}

variable "ec2_instance_max" {
  type = number
  description = "Num of instances maximum"
}

variable "ec2_instance_type" {
  type = string
  description = "type of EC2 instance"
}