data "aws_ami" "ubuntu" {

  most_recent      = true
  owners           = ["704109570831"]
}
# data "terraform_remote_state" "network" {
#       backend = "local"
#       config = {
#       path = "../networking/terraform.tfstate"
#       }
# }