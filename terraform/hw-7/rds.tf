# subnet_group fror RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = merge(var.tags, { Name = "db-subnet-group" })
}
# RDS Instance
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  db_name              = "db_name1"
  username             = "db_user"
  password             = "db_password"
  identifier = "hw7-rds-endpoint"
  skip_final_snapshot  = true
  multi_az             = false
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  tags = merge(var.tags, { Name = "rds-instance" })
}
resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/rds/endpoint"
  type  = "String"
  value = aws_db_instance.default.endpoint
}