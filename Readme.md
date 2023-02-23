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

## Requirments

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