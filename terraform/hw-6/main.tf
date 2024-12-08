resource "aws_vpc" "vpc-hw6" {
  cidr_block = var.cidr_pvc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "hw-6-vpc",
    env = "test",
    DZ = "hw6"
  }
}
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc-hw6.id
  cidr_block        = var.cidr_subnet_public
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone
  tags = {
    Name = "hw-6-public-subnet",
    env = "test",
    DZ = "hw6"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc-hw6.id
  cidr_block        = var.cidr_subnet_private
  availability_zone = var.availability_zone
  tags = {
    Name = "hw-6-private-subnet",
    env = "test",
    DZ = "hw6"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-hw6.id

  tags = {
    Name = "hw-6-igw",
    env  = "test",
    DZ   = "hw6"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc-hw6.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "hw-6-public-rt",
    env  = "test",
    DZ   = "hw6"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}