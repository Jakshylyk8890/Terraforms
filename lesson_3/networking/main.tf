provider "aws" {
     
      region     = "us-west-1"
}

// Create VPC
resource "aws_vpc" "jeks" {
      cidr_block = "10.1.0.0/16"
      tags = {
      Name = "Jaks-vpc"
      }
}

// Create Internet Gateway
resource "aws_internet_gateway" "gw" {
      vpc_id = aws_vpc.jeks.id

      tags = {
      Name = "jaks-internet-gateway"
      }
}

//Route Table
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

//Create Route Table
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

// Route Table association
resource "aws_route_table_association" "a" {
        count = 2
        subnet_id      = aws_subnet.pub1.*.id[count.index]
        route_table_id = aws_route_table.rt.*.id[count.index]
}
// Create Subnet
resource "aws_subnet" "pub1" {
        count = 2
        vpc_id     = aws_vpc.jeks.id
        cidr_block = "10.1.${count.index}.0/24"
        availability_zone = local.azs[count.index]
        tags = {
        Name = "Pub-subnet${count.index}"
        }
}