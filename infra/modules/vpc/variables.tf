variable "name" {
  type        = string
  description = "Name for resources"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs to deploy into"
}

variable "client_cidr_block" {
  type        = string
  description = "cidr block for AWS client VPN"
}

variable "server_cert_arn" {
  type = string
  description = "ARN of the server certificate manually imported to ACM"
}