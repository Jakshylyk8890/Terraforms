provider "aws" {
      region = "us-east-1"
  
}
resource "random_string" "random" {
      count = var.bucket_count
      length           = length(var.names)
      special          = false
      upper = false
}
resource "aws_s3_bucket" "b" {
      count = var.bucket_count != length(var.names) ? 3 : 1
      bucket = "jaks-${random_string.random[count.index].id}"

  tags = {
      Name        = "My bucket"
      }
}