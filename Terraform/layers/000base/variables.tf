/**
 * # 000base - variables.tf
 */

variable "region" {
  description = "The region are building into."
  type        = string
}

variable "environment" {
  description = "Build environment"
  type        = string
}

variable "layer" {
  description = "Terraform layer"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC main CIDR"
  type        = string
}

variable "subnet_PublicA" {
  description = "VPC Public Subnet A"
  type        = string
}

variable "subnet_PrivateA" {
  description = "VPC Private Subnet A"
  type        = string
}

variable "subnet_PublicB" {
  description = "VPC Public Subnet B"
  type        = string
}

variable "subnet_PrivateB" {
  description = "VPC Private Subnet B"
  type        = string
}