resource "aws_vpc" "vpc-hw6" {
  cidr_block = var.cidr_pvc
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
