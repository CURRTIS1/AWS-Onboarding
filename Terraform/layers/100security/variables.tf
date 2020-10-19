/**
 * # 100security - variables.tf
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
