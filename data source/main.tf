terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Fetch Latest Amazon Linux 2 AMI
data "aws_ami" "name" {
  most_recent = true
  owners      = ["amazon"]
  #regex       = []

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

output "aws_ami" {
  value = data.aws_ami.name.id
}

# Security Group Data Source
data "aws_security_group" "nginx-sg" {
  filter {
    name   = "tag:Name"
    values = ["nginx-sg"]
  }
}

# Fetch VPC Details
data "aws_vpc" "kedar-vpc" {
  filter {
    name   = "tag:Name"
    values = ["kedar-vpc"]
  }
}

# Get Availability Zones
data "aws_availability_zones" "names" {
  state = "available"
}

# Get Private Subnet ID
data "aws_subnet" "name" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.kedar-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["private-subnet"]
  }
}

# EC2 Instance - Sample Server
resource "aws_instance" "kedar-server" {
  ami             = data.aws_ami.name.id
  instance_type   = "t3.nano"
  subnet_id       = data.aws_subnet.name.id
  security_groups = [data.aws_security_group.nginx-sg.id]

  tags = {
    Name = "SampleServer"
  }
}

# EC2 Instance - Nginx Server
resource "aws_instance" "nginxserver" {
  ami             = "ami-0c50b6f7dc3701ddd"
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnet.name.id
  security_groups = [data.aws_security_group.nginx-sg.id]

  tags = {
    Name = "kedar-NginxServer"
  }
}

# Outputs
output "aws_zones" {
  value = data.aws_availability_zones.names.names
}

# AWS Account and Region Details
data "aws_caller_identity" "name" {}
data "aws_region" "name" {}

output "caller_info" {
  value = data.aws_caller_identity.name.account_id
}

output "region_name" {
  value = data.aws_region.name
}

output "security_group" {
  value = data.aws_security_group.nginx-sg.id
}

output "vpc_id" {
  value = data.aws_vpc.kedar-vpc.id
}
