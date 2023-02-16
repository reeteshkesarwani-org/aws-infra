/* creation of vpc for the server */
resource "aws_vpc" "vpc_network" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc_network"
    Environment = "${var.environment}"
  }
}
/* Setting up of Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

/* Setting up for the Private subnet */
resource "aws_subnet" "pvt_subnet" {
  vpc_id                  = aws_vpc.vpc_network.id
  count                   = length(var.pvt_subnets_cidr)
  cidr_block              = element(var.pvt_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "pvt-subnet-${var.environment}-${element(var.availability_zones, count.index)}"
    Environment = "${var.environment}"
  }
}

/* Setting up for the Public subnet */
resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.vpc_network.id
  count                   = length(var.pub_subnets_cidr)
  cidr_block              = element(var.pub_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "pub-subnet-${var.environment}-${element(var.availability_zones, count.index)}"
    Environment = "${var.environment}"
  }
}



/* Creation of Routing table the private subnets */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name        = "pvt-route-table-${var.environment}"
    Environment = "${var.environment}"
  }
}

/* Creation of Routing table the public  subnets */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name        = "pub-route-table-${var.environment}"
    Environment = "${var.environment}"
  }
}
/* Setting for the public table to internet Gateway */
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
/* Route Table for association of public subnet*/
resource "aws_route_table_association" "public" {
  count          = length(var.pub_subnets_cidr)
  subnet_id      = element(aws_subnet.pub_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
/* Route Table for association of private subnet*/
resource "aws_route_table_association" "private" {
  count          = length(var.pvt_subnets_cidr)
  subnet_id      = element(aws_subnet.pvt_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
