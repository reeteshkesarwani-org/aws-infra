variable "region" {
  description = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}
variable "pub_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}
  
variable "pvt_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}

variable "ami" {
description = "value of ami"
}

variable "DATABASE_USER"{
description = "value of database username"
}
variable "DATABASE_PASSWORD"{
description = "value of database password"
}
variable "PORT"{
description = "value of database port"
}
variable "DATABASE_NAME"{
description = "value of database name"
}

variable "root_domain"{
description="value for the root domain"
}