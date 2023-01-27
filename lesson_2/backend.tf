# resource "aws_s3_bucket" "b" {
#   bucket = "my-lsf-byket"

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }
# resource "aws_db_instance" "default" {
#   allocated_storage    = 10
#   db_name              = "mydb"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.micro"
#   username             = "jakshylyk"
#   password             = "lll9090"
#   skip_final_snapshot  = true
# }