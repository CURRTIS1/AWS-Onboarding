provider "aws" {
  region     = "us-east-1"
  version    = "~> 3.3.0"
  access_key = "var.aws_access_key"
  secret_key = "var.aws_secret_key"
}