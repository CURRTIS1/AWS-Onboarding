# AWS-Onboarding
Environment to practice IAC for AWS

### In order to use the Linux Academy Sandbox to spin up the environment:

#### Set the local stored credentials to your personal keys
```
aws configure set aws_access_key_id ************************** --profile default
aws configure set aws_secret_access_key ************************** --profile default
aws configure set region us-east-1 --profile default
```

#### In your main.tf file use the default stored credentials
```
terraform {
  required_version = "0.13.0"

  backend "s3" {
    bucket = "*************"
    key    = "******************"
    region = "us-east-1"
    encrypt = true
  }
}
```

#### Store the Linux Academy credentials in your secrets file
```
variable "aws_access_key" {
  description = "The AWS Access Key"
  default     = "**************************"
}

variable "aws_secret_key" {
  description = "The AWS Secret Key"
  default     = "**************************"
}
```

#### Reference the stored credentials in your provider block
```
provider "aws" {
  version = "~> 3.3.0"
  region  = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
```