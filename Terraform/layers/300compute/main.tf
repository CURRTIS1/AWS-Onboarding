/**
 * # 300compute - main.tf
 */

terraform {
  required_version = "0.13.4"

  backend "s3" {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.300compute.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  version    = "~> 3.3.0"
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  tags = {
    environment = var.environment
    layer       = var.layer
    terraform   = "true"
  }
}

data "terraform_remote_state" "state_000base" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.000base.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "state_100security" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.100security.tfstate"
    region = "us-east-1"
  }
}


## ----------------------------------
## Windows test instance
/**
resource "aws_instance" "ec2_instance_windows" {
  ami                    = var.ami_type_windows
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_web]
  subnet_id              = data.terraform_remote_state.state_000base.outputs.subnet_public[0]
  iam_instance_profile   = data.terraform_remote_state.state_000base.outputs.ssm_profile

  tags = merge(
    local.tags,
    {
      Name = "Test Windows Instance"
    }
  )
}
 */

## ----------------------------------
## Linux test instance
/**
resource "aws_instance" "ec2_instance_linux" {
  ami                    = var.ami_type_linux
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_web]
  subnet_id              = data.terraform_remote_state.state_000base.outputs.subnet_public[0]
  iam_instance_profile   = data.terraform_remote_state.state_000base.outputs.ssm_profile

  tags = merge(
    local.tags,
    {
      Name = "Test Linux Instance"
    }
  )
}
 */

## ----------------------------------
## ELB Target Group

resource "aws_lb_target_group" "elb_target_group" {
  name = "Onboarding2020-ELB-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.state_000base.outputs.vpc_id
  health_check {
    enabled = true
    path = "/"
    port = "80"
    interval = 30
  }
}


## ----------------------------------
## ELB

resource "aws_lb" "myelb" {
  name = "Onboarding2020-ELB"
  load_balancer_type = "application"
  subnets = data.terraform_remote_state.state_000base.outputs.subnet_public
  security_groups = [data.terraform_remote_state.state_100security.outputs.sg_alb]
  ip_address_type = "ipv4"
  internal = false

}


## ----------------------------------
## ELB Listener

resource "aws_lb_listener" "myelblistener" {
  load_balancer_arn = aws_lb.myelb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.elb_target_group.arn
  }
}


## ----------------------------------
## ASG Launch Configuration

resource "aws_launch_template" "mylaunchtemplate" {
  image_id = var.ami_type_linux
  instance_type = var.instance_type
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_web]
  iam_instance_profile {
    name = data.terraform_remote_state.state_000base.outputs.ssm_profile
  }
}


## ----------------------------------
## ASG

resource "aws_autoscaling_group" "myasg" {
  name = "Onboarding2020-ASG"
  max_size = var.autoscale_max
  min_size = var.autoscale_max
  target_group_arns = [aws_lb_target_group.elb_target_group.arn]
  vpc_zone_identifier = data.terraform_remote_state.state_000base.outputs.subnet_private
  health_check_type = "EC2"
  launch_template {
    name = aws_launch_template.mylaunchtemplate.name
    version = "$Default"
  }

  tag {
    key = "Name"
    value = "EC2-Linux"
    propagate_at_launch = true
  }
}