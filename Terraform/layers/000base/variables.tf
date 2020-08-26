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

variable "state_bucket" {
  description = "The bucket to store the terraform state"
  default     = "Curtis-Terraform-Test-2020b"
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  default     = "t2.micro"
}


variable "alb_name" {
  description = "The readable friendly name of the load balancer"
  default     = "my-alb"
}

