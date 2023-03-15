variable "region" {
  description = "us-east-1"
  default     = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
  default     = "dev"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  default     = "10.0.0.0/16"

}
variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}
variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami"{
description = "Given the value of ami"
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
 description="setting up the root_domain"
}