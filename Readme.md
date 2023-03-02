# Assignment-3 Infrastructure as a  code

## Purpose

We are going to start setting up our AWS infrastructure. This assignment will focus on setting up our networking resources such as Virtual Private Cloud (VPC), Internet Gateway, Route Table, and Routes. We will use Terraform for infrastructure setup and tear down.

## Requirments

Here is what you need to do for networking infrastructure setup:

Create Virtual Private Cloud (VPC)

Create subnets in your VPC. You must create 3 public subnets and 3 private subnets, each in a different availability zone in the same region in the same VPC.

Create an Internet Gateway. resource and attach the Internet Gateway to the VPC.

Create a public route table. Attach all public subnets created to the route table.

Create a private route table. Attach all private subnets created to the route table.

Create a public route in the public route table created above with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target.


 ## Configuration of AWS
*We need to configure the aws profile in the terminal* 

we will use `aws configure --profile (demo/dev)` 

aws configure --profile  demo/dev

AWS Access Key ID [None]: enter access key here

AWS Secret Access Key [None]: enter secret access key hereKEY

Default region name [None]: default region name

Default output format [None]: what is output


## Usage Instructions 

Copy and paste into your Terraform variables(tfvars file), insert or update the
variables inside the file, and run `terraform init`:

Run `terraform plan` - command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure

Run `terraform apply` - Terraform automatically creates a new execution plan as if you had run terraform plan prompts you to approve that plan, and takes the indicated actions.

# Assignment-4 Packer & AMIs

## Purpose 
Building Custom Application AMI using Packer, Continuous Integration: Add New GitHub Actions Workflow for Web App, Infrastructure as Code w/ Terraform, EC2 Instance

## Requirements

The EC2 instance must be launched in the VPC created by your Terraform template. You cannot launch the EC2 instance in the default VPC.

Create an EC2 security group for your EC2 instances that will host web applications.

Add ingress rule to allow TCP traffic on ports 22, 80, 443, and port on which your application runs from anywhere in the world.

This security group will be referred to as the application security group.

Create an EC2 instance with the following specifications. For any parameter not provided in the table below, you may go with default values. The EC2 instance should belong to the VPC you have created.

Application security group should be attached to this EC2 instance.
Make sure the EBS volumes are terminated when EC2 instances are terminated.

Parameter	                Value

Amazon Machine Image (AMI)	Your custom AMI

Instance Type	           `t2.micro`
Protect against             `accidental termination	No`
Root Volume Size	        `50`
Root Volume Type	        `General Purpose SSD (GP2)`

## Bootstrapping Database

The application is expected to automatically bootstrap the database at startup.

Bootstrapping creates the schema, tables, indexes, sequences, etc., or updates them if their definition has changed.

The database cannot be set up manually by running SQL scripts.

It is highly recommended that you use ORM frameworks such as Hibernate (for java), SQLAlchemy (for python), and Sequelize (for Node.js).

## Configuration of AWS

*We need to configure the aws profile in the terminal*

we will use `aws configure --profile (demo/dev)`

aws configure --profile  demo/dev

AWS Access Key ID [None]: enter access key here

AWS Secret Access Key [None]: enter secret access key hereKEY

Default region name [None]: default region name

Default output format [None]: what is output


## Usage Instructions
Copy and paste into your Terraform variables(tfvars file), insert or update the
variables inside the file, and run `terraform init`:

Run `terraform plan` - command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure

Run `terraform apply` - Terraform automatically creates a new execution plan as if you had run terraform plan prompts you to approve that plan, and takes the indicated actions.


# Assignment-5 Addition of DB

## Purpose
In this assignment, you will update the Terraform template for the application stack to add the following resources:DB Security Group,S3 Bucket,RDS Parameter Group,RDS Instance,User Data,IAM Policy,IAM Role,Web Application

## Requirements

## DB Security Group

Create an EC2 security group for your RDS instances.

Add ingress rule to allow TCP traffic on the port 3306 for MySQL/MariaDB or 5432 for PostgreSQL.

The Source of the traffic should be the application security group. 

Restrict access to the instance from the internet.

This security group will be referred to as the database security group.

## S3 Bucket

Create a private S3 bucket with a randomly generated bucket name depending on the environment.

Make sure Terraform can delete the bucket even if it is not empty.

To delete all objects from the bucket manually use the CLI before you delete the bucket you can use the following AWS CLI command that may work for removing all objects from the bucket. aws s3 rm s3://bucket-name --recursive.

Enable default encryption for S3 BucketsLinks to an external site..

Create a lifecycle policy for the bucket to transition objects from STANDARD storage class to STANDARD_IA storage class after 30 days.

## RDS Parameter Group

A DB parameter group acts as a container for engine configuration values that are applied to one or more DB instances. Create a new parameter group to match your database (Postgres or MySQL) and its version. Then RDS DB instance must use the new parameter group and not the default parameter group.

## RDS Instance
WARNING: Setting Public accessibility to true will expose your instance to the internet.

Your RDS instance should be created with the following configuration. You may use default values/settings for any property not mentioned below.

Property	         Value
Database Engine	     MySQL/PostgreSQL
DB Instance Class	 db.t3.micro
Multi-AZ deployment	 No
DB instance identifier	csye6225
Master username	      csye6225
Master password	      pick a strong password
Subnet group	      Private subnet for RDS instances
Public accessibility	  No
Database name	       csye6225
Database security group should be attached to this RDS instance.

## User Data
EC2 instance should be launched with user dataLinks to an external site..
Database username, password, hostname, and S3 bucket name should be passed to the web application using user dataLinks to an external site..
The S3 bucket name must be passed to the application via EC2 user data.

## IAM Policy

WebAppS3 the policy will allow EC2 instances to perform S3 buckets. This is required for applications on your EC2 instance to talk to the S3 bucket.

Note: Replace * with appropriate permissions for the S3 bucket to create security policies.

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::YOUR_BUCKET_NAME",
                "arn:aws:s3:::YOUR_BUCKET_NAME/*"
            ]
        }
    ]
}

## IAM Role
Create an IAM role EC2-CSYE6225 for the EC2 service and attach the WebAppS3 policy to it. You will attach this role to your EC2 instance.

## Web Application
The web application’s database must be the RDS instance launched by the Terraform template when running on the EC2 instance. You can no longer install/use the local database on the EC2 instance.
