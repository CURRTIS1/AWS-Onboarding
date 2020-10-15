/**
 * # 300compute - variables.tf
 */

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

variable "instance_type" {
  description = "The type of EC2 instance to use"
  default     = "t2.micro"
}


variable "alb_name" {
  description = "The readable friendly name of the load balancer"
  default     = "my-alb"
}
