# creating vpc for ecs project
resource "aws_vpc" "pro-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "pro-ecs"
  }
}

#creating public subnet-1 for ecs project
resource "aws_subnet" "pro-sub1" {
  vpc_id            = aws_vpc.pro-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "pro-sub1"
  }
}

#creating public subnet-2 for ecs project
resource "aws_subnet" "pro-sub2" {
  vpc_id            = aws_vpc.pro-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "pro-sub2"
  }
}


#creating private subnet-1 for ecs project
resource "aws_subnet" "priv-sub1" {
  vpc_id            = aws_vpc.pro-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "priv-sub1"
  }
}

#creating private subnet-2 for ecs project
resource "aws_subnet" "priv-sub2" {
  vpc_id            = aws_vpc.pro-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "priv-sub2"
  }
}

#create public_route_table for ecs project
resource "aws_route_table" "my_ecs_pub_rtb" {
  vpc_id = aws_vpc.pro-vpc.id

  route = []

  tags = {
    Name = "my_ecs_pub_rtb"
  }
}


#create private_route_table for ecs project
resource "aws_route_table" "my_ecs_priv_rtb" {
  vpc_id = aws_vpc.pro-vpc.id

  route = []

  tags = {
    Name = "my_ecs_priv_rtb"
  }
}

# public_route_table_association
resource "aws_route_table_association" "my_public_rtb_assoc" {
  subnet_id      = aws_subnet.pro-sub1.id
  route_table_id = aws_route_table.my_ecs_pub_rtb.id
}

#private route_table_association
resource "aws_route_table_association" "my_priv_rtb_assoc" {
  subnet_id      = aws_subnet.priv-sub1.id
  route_table_id = aws_route_table.my_ecs_priv_rtb.id
}

# creating internet_way for ecs project
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.pro-vpc.id

  tags = {
    Name = "ecs_igw"
  }
}

#creating aws_nat_gateway for ecs
resource "aws_nat_gateway" "ecs-nat-gateway" {
  allocation_id = aws_eip.eip-for-nat-gateway.id
  subnet_id     = aws_subnet.pro-sub1.id

  tags = {
    Name = "ecs-nat-gateway"
  }

}

# Allocate elastic ip address for ecs nat gateway
resource "aws_eip" "eip-for-nat-gateway" {
  vpc = true

  tags = {
    Name = "eip-for-nat-gateway"
  }

}

resource "aws_eip_association" "ecs_eip_assoc" {
  instance_id   = aws_instance.ecs_instance.id
  allocation_id = aws_eip.eip-for-nat-gateway.id
}

resource "aws_instance" "ecs_instance" {
  ami               = "ami-0be590cb7a2969726"
  availability_zone = "eu-west-1"
  instance_type     = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}