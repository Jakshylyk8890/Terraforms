
variable "subnets" {
   # default = data.terraform_remote_state.network.outputs.aws_subnet
  
}
variable "vpc"{
   type = string
   default = ""
}
variable "ingress" {
   default = ["22", "80", "443"]
}
variable "instance_type" {
   default = "t2.micro" 
}
variable "env" {
   default = "noname"
  
}