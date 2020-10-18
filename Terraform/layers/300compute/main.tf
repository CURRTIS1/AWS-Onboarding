/**
 * # 300compute - main.tf
 */

terraform {
  required_version = "0.13.4"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.300compute.tfstate"
    region = "us-east-1"
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

data "terraform_remote_state" "state_000base" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.000base.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "state_100security" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.100security.tfstate"
    region = "us-east-1"
  }
}


## ----------------------------------
## Windows test instance

resource "aws_instance" "ec2_instance_windows" {
  ami                    = var.ami_type_windows
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_web]
  subnet_id              = data.terraform_remote_state.state_000base.outputs.subnet_public[0]
  iam_instance_profile   = data.terraform_remote_state.state_000base.outputs.ssm_profile

  tags = merge(
    local.tags,
    {
      Name = "Test Windows Instance"
    }
  )
}


## ----------------------------------
## Linux test instance

resource "aws_instance" "ec2_instance_linux" {
  ami                    = var.ami_type_linux
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_web]
  subnet_id              = data.terraform_remote_state.state_000base.outputs.subnet_public[0]
  iam_instance_profile   = data.terraform_remote_state.state_000base.outputs.ssm_profile

  tags = merge(
    local.tags,
    {
      Name = "Test Linux Instance"
    }
  )
}