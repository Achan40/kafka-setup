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

output "client_cidr_block" {
  description = "CIDR block for client VPN connection"
  value = aws_ec2_client_vpn_endpoint.cert.client_cidr_block
}