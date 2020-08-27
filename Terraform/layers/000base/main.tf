/**
 * # 000base - main.tf
 */

terraform {
  required_version = "0.13.0"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.000base.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}


provider "aws" {
  version = "~> 3.3.0"
  region  = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


locals {
  tags = {
    Environment = var.environment
    Layer       = var.layer
    Terraform   = "true"
  }
}


## ----------------------------------
## Main VPC

resource "aws_vpc" "main_vpc" {
  cidr_block         = var.vpc_cidr
  instance_tenancy   = "default"
  enable_dns_support = true

  tags = merge(
    local.tags,
    {
      Name = "VPC-Curtis-Onboarding"
    }
  )
}


## ----------------------------------
## Internet Gateway

resource "aws_internet_gateway" "main_IGW" {
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

resource "aws_subnet" "subnet_Public" {
  count = 2
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_Public_range[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      PublicCIDR = "true", Name = format("PublicSubnet-%s", count.index + 1)
    }
  )
}

resource "aws_subnet" "subnet_Private" {
  count = 2
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_Private_range[count.index]
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

resource "aws_eip" "NatGWIP" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.main_IGW]

  tags = merge(
    local.tags,
    {
      ElasticIP = "true", Name = format("NatGWIP-%s", count.index + 1)
    },
  )
}


## ----------------------------------
## Nat Gateway

resource "aws_nat_gateway" "NatGW" {
  count = 2
  allocation_id = element(aws_eip.NatGWIP.*.id, count.index)
  subnet_id = element(aws_subnet.subnet_Public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main_IGW]

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
  vpc_id            = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_IGW.id
  }

  tags = merge(
    local.tags,
    {
      Name = "Public Route Table"
      PublicRouteTable = "true"
    }
  )
}

resource "aws_route_table" "routetable_private" {
  vpc_id            = aws_vpc.main_vpc.id
  count = 2
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.NatGW.*.id, count.index)
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
  count = 2
  subnet_id = element(aws_subnet.subnet_Public.*.id, count.index)
  route_table_id = aws_route_table.routetable_public.id
}

resource "aws_route_table_association" "routetableassociation_private" {
  count = 2
  subnet_id = element(aws_subnet.subnet_Private.*.id, count.index)
  route_table_id = element(aws_route_table.routetable_private.*.id, count.index)
}