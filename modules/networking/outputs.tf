output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "web_security_group_id" {
  value = aws_security_group.web.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "availability_zones" {
  value = local.azs
}
