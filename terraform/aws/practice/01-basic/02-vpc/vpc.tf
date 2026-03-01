terraform {
  required_providers {
    aws = {
        version = "~>6.0"
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = ap-south-1
}

resource "aws_vpc" "tf-demo-vpc" {
  cidr_block = ["10.0.0.0/16"]
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "tf-demo-vpc"
  }
}

resource "aws_subnet" "tf-demo-sub-1" {
  cidr_block = ["10.0.0.0/20"]
  vpc_id = aws_vpc.tf-demo-vpc.id
  availability_zone = "ap-south-1a"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    "Name" = "tf-demo-sub-1"
  }
}

resource "aws_internet_gateway" "tf-demo-itgw" {
  vpc_id = aws_vpc.tf-demo-vpc.id
}

resource "aws_route_table" "tf-demo-rt" {
  vpc_id = aws_vpc.tf-demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-demo-itgw.id
  }
}

resource "aws_route_table_association" "tf-demo-association" {
  subnet_id = aws_subnet.tf-demo-sub-1.id
  route_table_id = aws_route_table.tf-demo-rt.id
}