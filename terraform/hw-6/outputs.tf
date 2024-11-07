output "vpc_id" {
  value = aws_vpc.vpc-hw6.id
}

output "subnet_public_id" {
  value = aws_subnet.public.id
}

output "subnet_private_id" {
  value = aws_subnet.private.id
}

output "sg_front_id" {
  value = aws_security_group.sg_front.id
}

output "sg_back_id" {
  value = aws_security_group.sg_back.id
}

output "web_instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "db_instance_private_ip" {
  value = aws_instance.db.private_ip
}

output "web_instance_dns" {
  value = aws_instance.web.public_dns
}  