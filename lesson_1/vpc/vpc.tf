terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
 
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "jeks" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Jaks-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.jeks.id

  tags = {
    Name = "jaks-internet-gateway"
  }
}


resource "aws_route_table" "rt" {
   count = 3
  vpc_id = aws_vpc.jeks.id

  route {
  
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route${count.index}"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.jeks.id

  route {
  
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "routemanually"
  }
}

resource "aws_route_table_association" "a" {
  count = 3
  subnet_id      = aws_subnet.pub1.*.id[count.index]
  route_table_id = aws_route_table.rt.*.id[count.index]
}
# resource "aws_route_table_association" "b" {
  
#   subnet_id      = aws_subnet.pub2.id
#   route_table_id = aws_route_table.rt1.id
# }


resource "aws_subnet" "pub1" {
  count = 3
  vpc_id     = aws_vpc.jeks.id
  cidr_block = "10.1.${count.index}.0/24"
tags = {
    Name = "Pub-subnet${count.index}"
  }
}
# resource "aws_subnet" "pub2" {
#   vpc_id     = aws_vpc.jeks.id
#   cidr_block = "10.1.9.0/24"
# tags = {
#     Name = "Pub-subnet-90"
  
# }
# }
resource "aws_security_group" "js-sg" {
  name        = "js-sg"
  description = "Example security group"
  vpc_id      = aws_vpc.jeks.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "jaks_key" {
  key_name = "jaks_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "jaks-instance" {
  count = 3
  ami           = "ami-00874d747dde814fa"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.jaks_key.key_name
  vpc_security_group_ids = [aws_security_group.js-sg.id]
  subnet_id               = aws_subnet.pub1.1.id
  associate_public_ip_address = true
  tags = {
    Name = "jakshylyk-instance${count.index}"
  }
}