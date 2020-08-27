/**
 * # 200data - main.tf
 */


 terraform {
  required_version = "0.13.0"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.100data.tfstate"
    region = "us-east-1"
  }
}