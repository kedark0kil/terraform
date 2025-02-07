#Create a VPC
resource "aws_vpc" "kedar_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "kedar_vpc"
  }
}

#Private subnet
resource "aws_subnet" "private-subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.kedar_vpc.id
  tags = {
    Name = "private-subnet"
  }
}

#Public subnet
resource "aws_subnet" "public-subnet" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.kedar_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

#Internet gateway
resource "aws_internet_gateway" "kedar-igw" {
  vpc_id = aws_vpc.kedar_vpc.id
  tags = {
    Name = "kedar-igw"
  }
}

#Routing table
resource "aws_route_table" "kedar-rt" {
  vpc_id = aws_vpc.kedar_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kedar-igw.id
  }
}

resource "aws_route_table_association" "public-sub" {
  route_table_id = aws_route_table.kedar-rt.id
  subnet_id      = aws_subnet.public-subnet.id
}