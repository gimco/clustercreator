output "vpc_id" {
  description = "The id of the VPC."
  value = aws_vpc.vpc.id
}

output "sg_id" {
  description = "The id of the security group."
  value = aws_security_group.web.id
}
