/**
 * # 000base - main.tf
 */

terraform {
  required_version = "0.13.0"

  backend "S3" {
    bucket = "Curtis-Terraform-Test-2020"
    key = "terraform.000base.tfstate"
    region     = var.region
  }
}

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

