output "vpc_id"{
    value = aws_vpc.vpc.id
}

output "public_subnet_ids"{
   value =  aws_subnet.public_subnet.*.id
}

output "private_subnet_ids"{
    value = aws_subnet.private_subnet.*.id
}

output "db_sg" {
  value       = aws_security_group.db_sg.id
  description = "database Security group"
}

output "private_sg_ASG" {
  value       = aws_security_group.private_sg.id
  description = "private_sg for ASG"
}

output "availability_zones_ASG" {
  value       = data.aws_availability_zones.available.names.*
  description = "availability zones ASG"
}

