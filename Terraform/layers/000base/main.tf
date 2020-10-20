/**
 * # 000base - main.tf
 */

terraform {
  required_version = "0.13.4"

  backend "s3" {
    bucket  = "curtis-terraform-test-2020"
    key     = "terraform.000base.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  version    = "~> 3.3.0"
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  tags = {
    environment = var.environment
    layer       = var.layer
    terraform   = "true"
  }
}


## ----------------------------------
## SSM IAM role

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssmrole_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"
  role = aws_iam_role.ssm_role.name
}


## ----------------------------------
## Main VPC

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.tags,
    {
      Name = "VPC-Curtis-Onboarding"
    }
  )
}


## ----------------------------------
## Internet Gateway

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    local.tags,
    {
      Name = "myIG"
    }
  )
}


## ----------------------------------
## Subnets

resource "aws_subnet" "subnet_public" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_public_range[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      PublicCIDR = "true", Name = format("PublicSubnet-%s", count.index + 1)
    }
  )
}

resource "aws_subnet" "subnet_private" {
  count             = 2
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_private_range[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.tags,
    {
      PrivateCIDR = "true", Name = format("PrivateSubnet-%s", count.index + 1)
    }
  )
}


## ----------------------------------
## Elastic IPs

resource "aws_eip" "natgwip" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.main_igw]

  tags = merge(
    local.tags,
    {
      ElasticIP = "true", Name = format("NatGWIP-%s", count.index + 1)
    },
  )
}


## ----------------------------------
## Nat Gateway

resource "aws_nat_gateway" "natgw" {
  count         = 2
  allocation_id = element(aws_eip.natgwip.*.id, count.index)
  subnet_id     = element(aws_subnet.subnet_public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main_igw]

  tags = merge(
    local.tags,
    {
      NatGW = "true", Name = format("NatGW-%s", count.index + 1)
    },
  )
}


## ----------------------------------
## Route Tables

resource "aws_route_table" "routetable_public" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = merge(
    local.tags,
    {
      Name             = "Public Route Table"
      PublicRouteTable = "true"
    }
  )
}

resource "aws_route_table" "routetable_private" {
  vpc_id = aws_vpc.main_vpc.id
  count  = 2
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
  }

  tags = merge(
    local.tags,
    {
      PrivateRouteTable = "true", Name = format("Private Route Table-%s", count.index + 1)
    }
  )
}


## ----------------------------------
## Route Table Associations

resource "aws_route_table_association" "routetableassociation_public" {
  count          = 2
  subnet_id      = element(aws_subnet.subnet_public.*.id, count.index)
  route_table_id = aws_route_table.routetable_public.id
}

resource "aws_route_table_association" "routetableassociation_private" {
  count          = 2
  subnet_id      = element(aws_subnet.subnet_private.*.id, count.index)
  route_table_id = element(aws_route_table.routetable_private.*.id, count.index)
}


## ----------------------------------
## SSM 

resource "aws_ssm_association" "ssm_install" {
  name             = "AWS-UpdateSSMAgent"
  association_name = "Onboarding2020-SystemAssociationForSsmAgentUpdate"
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}