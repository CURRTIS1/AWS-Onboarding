provider "aws" {
  region     = var.region
  version    = "~> 3.3.0"
  access_key = "var.aws_access_key"
  secret_key = "var.aws_secret_key"
}