provider "aws" {
  region     = "us-east-1"
  version    = "~> 1.19"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}