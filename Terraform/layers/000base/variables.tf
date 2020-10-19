/**
 * # 000base - variables.tf
 */

variable "region" {
  description = "The region we are building into."
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

variable "subnet_public_range" {
  description = "VPC Public CIDR range"
  type        = list(string)
}

variable "subnet_private_range" {
  description = "VPC Private CIDR range"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}