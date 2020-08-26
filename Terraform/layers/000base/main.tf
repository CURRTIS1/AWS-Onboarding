/**
 * # 000base - main.tf
 */


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

