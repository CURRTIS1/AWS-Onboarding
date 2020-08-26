/**
 * # 000base - variabls.tf
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

variable "instance_type" {
  description = "The type of EC2 instance to use"
  default     = "t2.micro"
}

variable "AMI_type" {
  description = "The AMI to use"
  default     = "ami-02354e95b39ca8dec"
}

variable "autoscale_max" {
  description = "The max number of ec2 instances in the asg"
  default     = 1
}

variable "autoscale_min" {
  description = "The min number of ec2 instances in the asg"
  default     = 1
}

variable "alb_name" {
  description = "The readable friendly name of the load balancer"
  default     = "my-alb"
}

