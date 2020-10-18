/**
 * # 200data - main.tf
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
  version = "~> 3.3.0"
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}