/**
 * # 000base - main.tf
 */

terraform {
  required_version = "0.13.0"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.000base.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region  = var.region
  version = "~> 3.3.0"
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
}


locals {
  tags = {
    Environment = var.environment
    Layer       = var.layer
    Terraform   = "true"
  }
}


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


## Subnets

resource "aws_subnet" "subnet_PublicA" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_PublicA
  availability_zone = "us-east-1a"
  tags = merge(
    local.tags,
    {
      Name = "PublicA-us-east-1a"
    }
  )
}

resource "aws_subnet" "subnet_PrivateA" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_PrivateA
  availability_zone = "us-east-1a"
  tags = merge(
    local.tags,
    {
      Name = "PrivateA-us-east-1a"
    }
  )
}

resource "aws_subnet" "subnet_PublicB" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_PublicB
  availability_zone = "us-east-1b"
  tags = merge(
    local.tags,
    {
      Name = "PublicB-us-east-1b"
    }
  )
}

resource "aws_subnet" "subnet_PrivateB" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_PrivateB
  availability_zone = "us-east-1b"
  tags = merge(
    local.tags,
    {
      Name = "PrivateB-us-east-1b"
    }
  )
}




## Nat Gateway



#depends_on = [aws_internet_gateway.main_IGW]