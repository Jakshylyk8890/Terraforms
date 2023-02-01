//✎﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏𝐑𝐎𝐎𝐓 𝐌𝐎𝐃𝐔𝐋𝐄 𝐃𝐄𝐕﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏﹏
provider "aws" {
 
  
}

module "vpc-dev" {
    source = "../../modules/networking"
    vpc_cidr = "10.2.0.0/16"
    public_subnet_cidr = ["10.2.0.0/24"]
}

module "vpc-prod" {
    source = "../../modules/networking"
    env = "prod"
    # vpc_cidr = "10.2.0.0/16"
    # public_subnet_cidr = ["10.2.0.0/24"]
}

module "autosclaing" {
    source = "../../modules/autoscaling"
    env = "prod"
    subnets =   module.vpc-prod.aws_subnet
    vpc = module.vpc-prod.aws_vpc
}
