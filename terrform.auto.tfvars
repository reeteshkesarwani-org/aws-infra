//AWS 
region      = "us-east-1"
environment = "demo"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]    //List of Public subnet cidr range
private_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"] //List of private subnet cidr rang
availability_zones =  ["us-east-1a", "us-east-1b", "us-east-1c"]