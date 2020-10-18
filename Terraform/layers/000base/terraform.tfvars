/**
 * # 000base - terraform.tfvars
 */

region = "us-east-1"

environment = "Dev"

layer = "000base"

vpc_cidr = "172.16.0.0/16"

subnet_public_range = [
  "172.16.1.0/24",
  "172.16.2.0/24"
]

subnet_private_range = [
  "172.16.3.0/24",
  "172.16.4.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]