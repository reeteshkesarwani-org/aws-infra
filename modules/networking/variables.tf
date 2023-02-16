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
