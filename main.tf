module "networking" {
  source = "./modules/networking"

  region             = var.region
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  pub_subnets_cidr   = var.public_subnets_cidr
  pvt_subnets_cidr   = var.private_subnets_cidr
  availability_zones = var.availability_zones

}
