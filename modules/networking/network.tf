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

# Create a security group for your application instances
resource "aws_security_group" "example_app_security_group" {
  name_prefix = "example_app_security_group"
  vpc_id = aws_vpc.vpc_network.id
  depends_on  = [aws_vpc.vpc_network]
  # Ingress rules
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow your application port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "example_ec2_instance" {
  ami           = "ami-03030ce7a6c880e50"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.example_app_security_group.id]
  subnet_id     = aws_subnet.pub_subnet[0].id

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Prevent accidental termination of instance
  lifecycle {
    prevent_destroy = false
  }
   tags = {
    Name = "EC2 created"
  }
}