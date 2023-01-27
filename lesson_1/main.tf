terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}
provider "aws" {
  access_key = "AKIASQEDIVOQNAOAD4VP"
  secret_key = "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"
  region     = "us-east-1"
}



resource "aws_instance" "jakshylyk-instance" {
  ami           = "ami-00874d747dde814fa"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorlssd"
  }
}

