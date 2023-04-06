module "networking" {
  source = "./modules/networking"

  region             = var.region
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  pub_subnets_cidr   = var.public_subnets_cidr
  pvt_subnets_cidr   = var.private_subnets_cidr
  availability_zones = var.availability_zones
  ami=var.ami
  DATABASE_USER=var.DATABASE_USER
  DATABASE_PASSWORD=var.DATABASE_PASSWORD
  DATABASE_NAME=var.DATABASE_NAME
  PORT=var.PORT
  root_domain=var.root_domain
  keyname=var.keyname

}
