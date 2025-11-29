variable "project_tag" {
  type = string
  description = "Specify a tag for the group of services"
}

variable "ecs_cluster_name" {
  type = string
  description = "Name of the ECS cluster to create"
}

variable "vpc_id" {
  type = string
  description = "id of some existing VPC to launch the ECS cluster within"
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

variable "client_cidr_block" {
  type = string
  description = "CIDR block for client VPN connection"
}