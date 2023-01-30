provider "aws" {
  region = "us-east-1"
  access_key = "AKIAXTXHHCQH26WI77ZX" #cloudguru
  secret_key = "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"
}
data "terraform_remote_state" "network" {
      backend = "local"
      config = {
      path = "../lesson_3second/networking/terraform.tfstate"
      }
}


resource "aws_instance" "ec2-js" {
  for_each = toset(data.terraform_remote_state.network.outputs.aws_subnet)
  subnet_id = each.key
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_name != [] ? "t3.micro" : "t2.micro"
  tags = {
    Name = length(var.instance_name) <= 0 ? "jakshylyk-ec2" : "instance"
  }

}
resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.aws_vpc
}
resource "aws_lb_target_group_attachment" "attach-js" {
  for_each = aws_instance.ec2-js
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = each.value.id
  port             = 80
}