// ﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏𝐕𝐀𝐑𝐈𝐀𝐁𝐋𝐄𝐒﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏
variable "vpc_cidr" {
    default = "10.5.0.0/16"
}

variable "env" {
    default = "𝒋𝒂𝒌𝒔"
  
}
variable "public_subnet_cidr" {
    # type = string

    default = [
        "10.5.1.0/24",
        "10.5.2.0/24",
        "10.5.3.0/24",
    ]
  
}