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