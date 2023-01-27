provider "aws" {
  
      region     = "us-west-1"
}
// Launch Template
resource "aws_launch_template" "templ" {
      name = "instance"
      image_id = local.ami
      instance_type = "t2.micro"
      user_data = base64encode(file("userdata.sh"))
  network_interfaces {
      associate_public_ip_address = true
      security_groups = ["${aws_security_group.js-sg.id}"]
   
  }

}
//Security Group
resource "aws_security_group" "js-sg" {
    name        = "allow_http"
    vpc_id      = data.terraform_remote_state.network.outputs.aws_vpc
  dynamic "ingress" {
      for_each = ["22", "80", "443"]
  content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks =  ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   }
}
//Auto Scaling group
resource "aws_autoscaling_group" "asg" {
      name                      = "asg-js"
      max_size                  = 3
      min_size                  = 1
      desired_capacity          = 2
      vpc_zone_identifier = data.terraform_remote_state.network.outputs.aws_subnet
   launch_template {
      id      = aws_launch_template.templ.id
      version = "$Latest"
  }
}
data "terraform_remote_state" "network" {
      backend = "local"
      config = {
      path = "../networking/terraform.tfstate"
      }
}

// Application Load Balancer
resource "aws_lb" "lb-js" {
      name               = "jaks-lb"
      internal           = false
      load_balancer_type = "application"
      security_groups    = [aws_security_group.js-sg.id]
      subnets            =  data.terraform_remote_state.network.outputs.aws_subnet
}
// Create Target Group
resource "aws_lb_target_group" "tg-js" {
      name     = "tf-example-lb-tg"
      port     = 80
      protocol = "HTTP"
      vpc_id   = data.terraform_remote_state.network.outputs.aws_vpc
}
// Create Load Balancer
resource "aws_lb_listener" "front_end" {
      load_balancer_arn = aws_lb.lb-js.arn
      port              = "80"
      protocol          = "HTTP"
  default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg-js.arn
  }
}
// Attach Autoscaling to Load balancer
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
      autoscaling_group_name = aws_autoscaling_group.asg.id
      lb_target_group_arn    = aws_lb_target_group.tg-js.arn
}