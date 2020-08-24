


provider "aws" {
  region     = var.region
  version    = "~> 3.3.0"
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

resource "aws_instance" "ec2_instance" {
  ami           = var.AMI_type
  instance_type = var.instance_type
}