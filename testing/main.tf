provider "aws" {
  access_key = "AKIAW5RTJEQREGKG7LPF"
  secret_key = "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"
  region     = "us-west-2"
  token      = "arn:aws:s3:::rmtv-1"
}
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

terraform {
  backend "s3" {
    bucket         = "rmtv-1"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    #dynamodb_table = "<your_dynamo_dbtable_name>"
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


resource "aws_subnet" "pub1" {
  count = 3
  vpc_id     = aws_vpc.jeks.id
  cidr_block = "10.1.${count.index}.0/24"
  #availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
 availability_zone = local.azs[count.index]
tags = {
    Name = "Pub-subnet${count.index}"
  }
}
# variable "availability.zone.names" {
#   type    = list(string)
#   default = ["us-west-1a", "us-east-1b", "us-east-1d"]
# }


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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "jaks_key" {
  key_name = "jaks_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.pub1.0.id
  #private_ips     = ["10.0.1.0/24"]
  security_groups = [aws_security_group.js-sg.id]
  #associate_public_ip_address = true 
}



resource "aws_launch_template" "Jakshylyk" {
  name = "Jakshylyk"
 key_name  = aws_key_pair.jaks_key.key_name
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }
 image_id = "ami-00874d747dde814fa"

  instance_type = "t2.micro"
#   subnet_id  = aws_subnet.pub1.1.id

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Jakshylyk-template"
    }
  }
network_interfaces {
    security_groups = ["${aws_security_group.js-sg.id}"]
    associate_public_ip_address = true
  }
   #user_data = filebase64("${path.module}/example.sh")
   user_data = base64encode(file("./userdata.sh"))
}

resource "aws_autoscaling_group" "asg" {
  name                      = "foobar3-terraform-test"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  #launch_template     = aws_launch_template.jakshylyk.id
  vpc_zone_identifier       = [aws_subnet.pub1.0.id, aws_subnet.pub1.1.id]
  target_group_arns = [aws_lb_target_group.alb-target.arn]



    launch_template {
    id      = aws_launch_template.Jakshylyk.id
    version = "$Latest"
  }
 

}

 resource "aws_lb_target_group" "alb-target" {
  name        = "jakshylyk-target"
#   target_type = "alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.jeks.id
 }

resource "aws_lb" "test" {
  name               = "jakshylyk-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.js-sg.id]
  subnets            =  aws_subnet.pub1.*.id
}

# resource "aws_lb_target_group_attachment" "test" {
#    target_group_arn = [aws_lb_target_group.test.arn]
# }
resource "aws_lb_listener" "listens" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target.arn
  }
}

