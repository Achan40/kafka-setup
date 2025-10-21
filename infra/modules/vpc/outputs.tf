output "vpc_id" {
  description = "Id of the VPC"
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Ids of the private subnets within the VPC"
  value = values(aws_subnet.private)[*].id
}

output "public_subnet_ids" {
  description = "Ids of the public subnets within the VPC"
  value = values(aws_subnet.public)[*].id
}