output "vpc_id" {
  value = aws_vpc.vpc_hw7.id
}

output "web_instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_instance_dns" {
  value = aws_instance.web.public_dns
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}
output "public_url" {
  value = "https://${aws_instance.web.public_ip}.sslip.io"
}