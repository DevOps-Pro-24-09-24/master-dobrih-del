resource "aws_vpc" "vpc_hw7" {
  cidr_block = var.cidr_pvc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "PVC-hw7" })
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc_hw7.id
  cidr_block        = var.cidr_subnet_public
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone
  tags = merge(var.tags, { Name = "subnet-public" })
}
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.vpc_hw7.id
  cidr_block = var.cidr_subnet_private_a
  availability_zone = var.availability_zone
  tags = merge(var.tags, { Name = "subnet-private-a" })
}
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.vpc_hw7.id
  cidr_block = var.cidr_subnet_private_b
  availability_zone = var.availability_zone_b
  tags = merge(var.tags, { Name = "subnet-private-b" })
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_hw7.id
  tags = merge(var.tags, { Name = "igw-1" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_hw7.id

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
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id     = aws_subnet.public.id
  key_name = "test"
  user_data     = file(var.user_data_app)
  vpc_security_group_ids = [aws_security_group.sg_front.id]
  tags = merge(var.tags, { Name = "web-instance" })
}