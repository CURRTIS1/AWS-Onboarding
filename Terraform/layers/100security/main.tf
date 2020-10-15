/**
 * # 100security - main.tf
 */


terraform {
  required_version = "0.13.4"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.100security.tfstate"
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

data "terraform_remote_state" "state_000base" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.000base.tfstate"
    region = "us-east-1"
  }
}

## ----------------------------------
## Security Groups

resource "aws_security_group" "SG_ALB" {
  name   = "ALB Security Group"
  description = "ALB Security Group"
  vpc_id = data.terraform_remote_state.state_000base.outputs.vpc_id
  ingress {
    description = "Port 80 from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_Web" {
  name   = "WebServer Security Group"
  description = "WebServer Security Group"
  vpc_id = data.terraform_remote_state.state_000base.outputs.vpc_id
  ingress {
    description = "Port 80 from the Application Load Balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.SG_ALB.id]
  }
}

resource "aws_security_group" "SG_RDS" {
  name   = "RDS Security Group"
  description = "RDS Security Group"
  vpc_id = data.terraform_remote_state.state_000base.outputs.vpc_id
  ingress {
    description = "Port 3306 from the WebServer"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.SG_Web.id]
  }
}