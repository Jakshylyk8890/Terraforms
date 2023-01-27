provider "aws" {
    region = "us-east-1"
  
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_ubuntu" {

     owners           = ["454373518981"]
  
}

resource "aws_security_group" "js-sg" {
    name = "jaks"
    dynamic "ingress" {
        for_each = ["80", "22"]
        content {
          from_port = ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]

        }
      
    }
  
}