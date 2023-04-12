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
  vpc_id      = aws_vpc.vpc_network.id
  depends_on  = [aws_vpc.vpc_network]
  #Ingress rules
  ingress {
    description     = "Allow SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  # ingress {
  #   description = "Allow HTTP"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   security_groups = [aws_security_group.lb_sg.id]
  # }

  # ingress {
  #   description = "Allow HTTPS"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description     = "Allow your application port"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# # Create an EC2 instance
# resource "aws_instance" "example_ec2_instance" {
#   ami           = var.ami
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.example_app_security_group.id]
#   subnet_id     = aws_subnet.pub_subnet[0].id
#   iam_instance_profile    = aws_iam_instance_profile.app_instance_profile.name
#   root_block_device {
#     volume_size = 50
#     volume_type = "gp2"
#     delete_on_termination = true
#   }

#   # Prevent accidental termination of instance
#   lifecycle {
#     prevent_destroy = false
#   }
# #   code for the user data
# user_data = data.template_file.user_data.rendered
# # <<EOF
# # #!/bin/bash

# # echo "export DATABASE_USER=${var.DATABASE_USER} " >> /home/ec2-user/webapp/.env
# # echo "export DATABASE_PASSWORD=${var.DATABASE_PASSWORD} " >> /home/ec2-user/webapp/.env
# # echo "export PORT=${var.PORT} " >> /home/ec2-user/webapp/.env
# # echo "export DATABASE_HOST=$(echo ${aws_db_instance.db_instance.endpoint} | cut -d: -f1)" >> /home/ec2-user/webapp/.env
# # echo "export DATABASE_NAME=${var.DATABASE_NAME} " >> /home/ec2-user/webapp/.env
# # echo "export BUCKET_NAME=${aws_s3_bucket.mybucket.bucket} " >> /home/ec2-user/webapp/.env
# # echo "export BUCKET_REGION=${var.region} " >> /home/ec2-user/webapp/.env
# # sudo chmod +x setenv.sh
# # sh setenv.sh

# # sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
# #     -a fetch-config \
# #     -m ec2 \
# #     -c file:/home/ec2-user/webapp/cloudwatchconfig.json \
# #     -s
# # EOF

#    tags = {
#     Name = "EC2 created"
#   }
# }



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

#block public access to s3 bucket
resource "aws_s3_bucket_public_access_block" "s3Public" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
  kms_key_id = aws_kms_key.RdsKmsKey.arn
  storage_encrypted = true
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
  alias {
    name                   = aws_lb.application_lb.dns_name
    zone_id                = aws_lb.application_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudwatch_log_group" "csye6225" {
  name = "csye6225"

}


# cloudwatch policy for ec2 role
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.WebAppS3_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Load balancer security group
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.vpc_network.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "lb-sg"
  }
}

# Load balancer
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  internal           = false
  subnets            = aws_subnet.pub_subnet.*.id
  security_groups    = [aws_security_group.lb_sg.id]

  tags = {
    "Name" = "application-lb"
  }
}

# Load balancer target group
resource "aws_lb_target_group" "lb_target_group" {
  name                 = "application-target-group"
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = aws_vpc.vpc_network.id
  deregistration_delay = 20

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }

  stickiness {
    type = "lb_cookie"
  }
}

# Load balancer listener
# resource "aws_lb_listener" "lb_listener" {
#   load_balancer_arn = aws_lb.application_lb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.lb_target_group.arn
#   }
# }

# # Autoscaling launch configuration
# resource "aws_launch_configuration" "autoscaling_launch_configuration" {
#   name                        = "autoscaling-launch-configuration"
#   image_id                    = var.ami
#   instance_type               = "t2.micro"
#   key_name                    = var.keyname
#   security_groups             = [aws_security_group.example_app_security_group.id]
#   iam_instance_profile        = aws_iam_instance_profile.app_instance_profile.id
#   associate_public_ip_address = true

#   root_block_device {
#     volume_type = "gp2"
#     volume_size = 50
#   }

#   user_data = <<EOF
# #!/bin/bash
# echo "export DATABASE_USER=${var.DATABASE_USER} " >> /home/ec2-user/webapp/.env
# echo "export DATABASE_PASSWORD=${var.DATABASE_PASSWORD} " >> /home/ec2-user/webapp/.env
# echo "export PORT=${var.PORT} " >> /home/ec2-user/webapp/.env
# echo "export DATABASE_HOST=$(echo ${aws_db_instance.db_instance.endpoint} | cut -d: -f1)" >> /home/ec2-user/webapp/.env
# echo "export DATABASE_NAME=${var.DATABASE_NAME} " >> /home/ec2-user/webapp/.env
# echo "export BUCKET_NAME=${aws_s3_bucket.mybucket.bucket} " >> /home/ec2-user/webapp/.env
# echo "export BUCKET_REGION=${var.region} " >> /home/ec2-user/webapp/.env
# sudo chmod +x setenv.sh
# sh setenv.sh

# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#     -a fetch-config \
#     -m ec2 \
#     -c file:/home/ec2-user/webapp/cloudwatchconfig.json \
#     -s

# sudo systemctl restart webapp.service
# EOF
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_network_interface" "example_network_interface" {
#   subnet_id = aws_subnet.pub_subnet[0].id

# }

# Autoscaling launch template
resource "aws_launch_template" "autoscaling_launch_template" {
  name                   = "autoscaling_launchtemplate"
  image_id               = var.ami
  instance_type          = "t2.micro"
  key_name               = var.keyname
  //vpc_security_group_ids = [aws_security_group.example_app_security_group.id]
  //security_group             = [aws_security_group.example_app_security_group.id]
    network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.example_app_security_group.id]
  }
   block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = 50
      delete_on_termination = true
      kms_key_id=aws_kms_key.EBSKmsKey.arn
      encrypted = true
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.app_instance_profile.id
  }
  lifecycle {
    create_before_destroy = true
  }
  # associate_public_ip_address = true

  user_data = base64encode(<<-EOF
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

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -c file:/home/ec2-user/webapp/cloudwatchconfig.json \
        -s

    sudo systemctl restart webapp.service
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "autoscaling-instance"
    }
  }


  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}




# Autoscaling group
resource "aws_autoscaling_group" "autoscaling_group" {
  name                = "autoscaling-group"
  vpc_zone_identifier = aws_subnet.pub_subnet.*.id
  target_group_arns   = [aws_lb_target_group.lb_target_group.arn]
  default_cooldown    = 60
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  health_check_type   = "EC2"

  tag {
    key                 = "Name"
    value               = "csye6225-ec2"
    propagate_at_launch = true
  }
  launch_template {
    id      = aws_launch_template.autoscaling_launch_template.id
    version = "$Latest"
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
  }
}

# Autoscaling scale up policy
resource "aws_autoscaling_policy" "autoscaling_scale_up_policy" {
  name                   = "autoscaling_scale_up_policy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  scaling_adjustment     = 1
  cooldown               = 60


}

# Autoscaling scale down policy
resource "aws_autoscaling_policy" "autoscaling_scale_down_policy" {
  name                   = "autoscaling_scale_down_policy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  scaling_adjustment     = -1
  cooldown               = 60

}

# cloudwatch metric for scaling up
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name          = "cpu-alarm-high"
  alarm_description   = "Scale up if CPU is > 5% for 1 minute"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "5"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  alarm_actions       = [aws_autoscaling_policy.autoscaling_scale_up_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
}

# cloudwatch metric for scaling down
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_low" {
  alarm_name          = "cpu-alarm-low"
  alarm_description   = "Scale down if CPU is < 3% for 1 minute"
  comparison_operator = "LessThanThreshold"
  threshold           = "3"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  alarm_actions       = [aws_autoscaling_policy.autoscaling_scale_down_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
}


resource "aws_kms_key" "EBSKmsKey" {
  description = "KMS Key for EBS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
          ]
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow access for Key Administrators"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
          ]
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow attachment of persistent resources"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
          ]
        }
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource = "*"
      },
    ]
  })
}

# resource "aws_kms_alias" "EBSKeyAlias" {
#   name          = "alias/ebsKey"
#   target_key_id = aws_kms_key.EBSKmsKey.key_id
# }

resource "aws_kms_key" "RdsKmsKey" {
  description = "KMS Key for RDS"
  policy = jsonencode({
    Id       = "kms-key-for-rds"
    Version  = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          ]
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow access for Key Administrators"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
          ]
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
        ]
        Resource = "*"
      },
      {
        Sid       = "Allow use of the key"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
      },
      {
        Sid       = "Allow attachment of persistent resources"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
          ]
        }
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource = "*"
      },
    ]
  })
  deletion_window_in_days = 7
}

# data "aws_caller_identity" "current" {}

# resource "aws_kms_alias" "RDSKeyAlias" {
#   name          = "alias/rdsKey"
#   target_key_id = aws_kms_key.RdsKmsKey.key_id
# }



data "aws_caller_identity" "current" {}


//Load balancer listener
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.ssl_certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn

  }
}