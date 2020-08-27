/**
 * # 300compute - main.tf
 */

terraform {
  required_version = "0.13.0"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.300compute.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = var.AMI_type
  instance_type = var.instance_type
}