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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "example_ec2_instance" {
  ami           = var.ami
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.example_app_security_group.id]
  subnet_id     = aws_subnet.pub_subnet[0].id
  iam_instance_profile    = aws_iam_instance_profile.app_instance_profile.name
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Prevent accidental termination of instance
  lifecycle {
    prevent_destroy = false
  }
#   code for the user data
user_data = <<EOF
#!/bin/bash

echo "export DATABASE_USER=${var.DATABASE_USER} " >> /home/ec2-user/webapp/.env
echo "export DATABASE_PASSWORD=${var.DATABASE_PASSWORD} " >> /home/ec2-user/webapp/.env
echo "export PORT=${var.PORT} " >> /home/ec2-user/webapp/.env
echo "export DATABASE_HOST=$(echo ${aws_db_instance.db_instance.endpoint} | cut -d: -f1)" >> /home/ec2-user/webapp/.env
echo "export DATABASE_NAME=${var.DATABASE_NAME} " >> /home/ec2-user/webapp/.env
echo "export BUCKET_NAME=${aws_s3_bucket.mybucket.bucket} " >> /home/ec2-user/webapp/.env
echo "export BUCKET_REGION=${var.region} " >> /home/ec2-user/webapp/.env
sudo chmod +x setenv.sh
sh setenv.sh

EOF

   tags = {
    Name = "EC2 created"
  }
}


#Create database security group
resource "aws_security_group" "database" {
  name        = "database"
  description = "Security group for RDS instance for database"
  vpc_id      = aws_vpc.vpc_network.id
  ingress {
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = [aws_security_group.example_app_security_group.id]
  }

  tags = {
    "Name" = "database-sg"
  }
}


resource "random_id" "id" {
  byte_length = 8
}
#Create s3 bucket
resource "aws_s3_bucket" "mybucket" {
  #randomly generated bucket name
  bucket        = "mywebappbucket-${random_id.id.hex}"
  acl           = "private"
  force_destroy = true
  lifecycle_rule {
    id      = "StorageTransitionRule"
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

#Create iam policy to accress s3
resource "aws_iam_policy" "WebAppS3_policy" {
  name = "WebAppS3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.mybucket.bucket}/*"
        Resource = "arn:aws:s3:::${aws_s3_bucket.mybucket.bucket}/*"
      }
    ]
  })
}

#Create iam role for ec2 to access s3
resource "aws_iam_role" "WebAppS3_role" {
  name = "EC2-CSYE6225"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

#Create iam role policy attachment
resource "aws_iam_role_policy_attachment" "WebAppS3_role_policy_attachment" {
  role       = aws_iam_role.WebAppS3_role.name
  policy_arn = aws_iam_policy.WebAppS3_policy.arn
}


#attach iam role to ec2 instance
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "app_instance_profile"
  role = aws_iam_role.WebAppS3_role.name
}

#Create Rds subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db_subnet_group"
  description = "RDS subnet group for database"
  subnet_ids  = aws_subnet.pvt_subnet.*.id
  tags = {
    Name = "db_subnet_group"
  }
}

#Create Rds parameter group
resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "db-parameter-group"
  family      = "mysql8.0"
  description = "RDS parameter group for database"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

#Create Rds instance
resource "aws_db_instance" "db_instance" {
  identifier                = "csye6225"
  engine                    = "mysql"
  engine_version            = "8.0.28"
  instance_class            = "db.t3.micro"
  name                      = var.DATABASE_NAME
  username                  = var.DATABASE_USER
  password                  = var.DATABASE_PASSWORD
  parameter_group_name      = aws_db_parameter_group.db_parameter_group.name
  allocated_storage         = 20
  storage_type              = "gp2"
  multi_az                  = false
  skip_final_snapshot       = true
  final_snapshot_identifier = "final-snapshot"
  publicly_accessible       = false
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.database.id]
  tags = {
    Name = "db_instance"
  }
}

data "aws_route53_zone" "hosted_zone" {
  name = "${var.environment}.${var.root_domain}"
}


resource "aws_route53_record" "app_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.environment}.${var.root_domain}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.example_ec2_instance.public_ip]
}