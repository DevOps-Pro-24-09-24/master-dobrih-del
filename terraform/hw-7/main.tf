resource "aws_vpc" "vpc-hw7" {
  cidr_block = var.cidr_pvc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "PVE-hw7" })
}
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc-hw7.id
  cidr_block        = var.cidr_subnet_public
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone
  tags = merge(var.tags, { Name = "subnet-public" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-hw7.id
  tags = merge(var.tags, { Name = "igw-1" })
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc-hw7.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = "tr-public" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = var.ami_id_web
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = merge(var.tags, { Name = "web-instance" })
}
