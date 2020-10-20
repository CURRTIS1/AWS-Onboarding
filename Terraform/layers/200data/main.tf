/**
 * # 200data - main.tf

 RDS Limits
ONLY these Instance Types are allowed:
db.t2.micro to db.t2.medium
db.t3.micro to db.t3.medium
Cannot use Provisioned IOPS
Max Storage size of 50GB
 */


terraform {
  required_version = "0.13.4"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.200data.tfstate"
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
## RDS Subnet Group

resource "aws_db_subnet_group" "myrdsgroup" {
  name       = "my-rds-subnet-group"
  subnet_ids = data.terraform_remote_state.state_000base.outputs.subnet_private
}


## ----------------------------------
## RDS Instancs

resource "aws_db_instance" "myrdsinstance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.6.46"
  instance_class         = "db.t2.small"
  name                   = "db1"
  multi_az               = true
  identifier             = "database-1-instance-1"
  port                   = 3306
  db_subnet_group_name   = aws_db_subnet_group.myrdsgroup.id
  username               = "admin"
  password               = "Onboarding2020"
  skip_final_snapshot    = true
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_rds]

  tags = merge(
    local.tags
  )
}