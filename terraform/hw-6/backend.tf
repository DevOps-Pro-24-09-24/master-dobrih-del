resource "aws_instance" "db" {
  ami           = var.ami_id_db
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_back.id]

  tags = {
    Name = "db-instance",
    env  = "test",
    DZ   = "hw6"
  }
}

resource "aws_instance" "web" {
  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = false
    enable_resource_name_dns_a_record    = true
    hostname_type                        = "ip-name"
  }
  ami           = var.ami_id_web
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg_front.id]
  user_data     = file(var.user_data_app)
  tags = {
    Name = "app-instance",
    env  = "test",
    DZ   = "hw6"
  }
}