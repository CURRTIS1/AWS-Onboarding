/**
 * # 300compute - variables.tf
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

variable "ami_type_linux" {
  description = "The AMI to use"
  default     = "ami-0947d2ba12ee1ff75"
}

variable "ami_type_windows" {
  description = "The AMI to use"
  default     = "ami-0e315da6b15c55161"
}

variable "autoscale_max" {
  description = "The max number of ec2 instances in the asg"
  default     = 1
}

variable "autoscale_min" {
  description = "The min number of ec2 instances in the asg"
  default     = 1
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  default     = "t3.small"
}

variable "alb_name" {
  description = "The readable friendly name of the load balancer"
  default     = "my-alb"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}