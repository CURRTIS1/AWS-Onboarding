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

variable "extra_tags" {
  default = [
    {
      key                 = "environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "layer"
      value               = "300compute"
      propagate_at_launch = true
    },
    {
      key                 = "terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]
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

data "terraform_remote_state" "state_200data" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-test-2020"
    key    = "terraform.200data.tfstate"
    region = "us-east-1"
  }
}


## ----------------------------------
## EC2 Key Pair

resource "aws_key_pair" "mykp" {
  key_name   = "Onboarding2020-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxEjd30DO25FSHbpUEzmcGetk/vSP7u0TRkuISLhOudze5ULm6vyV6F+Tv4lNezINnc2U9JhDBU+wlxLXsbN1mefPVVl9w5suVARDz54z20T2IoXulme04RjteqeKkMw2/L5iSbc+uTJj59C57D/BJqxd54P+yLAbYB5QCcnACaCqHYEAJjWv5hQS5XE0WNmRzVkohsD7IoanmF23RRwXsS5tuoqObcjDUOruUj4/t/6lLXA6TwNE+f/XWD4mxBK0Ec1YX7IVGDfhvBHJ+03nY6xiQkLEqNyzLlGT9Y1S+9W/6z8O0TlzH79z3FuoPUTPlhUtdTYtt81RUTTxpKrDN curtis@CURTIS-mac"

  tags = merge(
    local.tags, {
      "Name" = "Onboarding2020-KP"
    }
  )
}


## ----------------------------------
## ELB Target Group

resource "aws_lb_target_group" "elb_target_group" {
  name     = "Onboarding2020-ELB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.state_000base.outputs.vpc_id
  health_check {
    enabled  = true
    path     = "/"
    port     = "80"
    interval = 30
  }

  tags = merge(
    local.tags, {
      "Name" = "Onboarding2020-ELB-TG"
    }
  )
}


## ----------------------------------
## ELB

resource "aws_lb" "myelb" {
  name               = "Onboarding2020-ELB"
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.state_000base.outputs.subnet_public
  security_groups    = [data.terraform_remote_state.state_100security.outputs.sg_alb]
  ip_address_type    = "ipv4"
  internal           = false

  tags = merge(
    local.tags, {
      "Name" = "Onboarding2020-ELB"
    }
  )
}


## ----------------------------------
## ELB Listener

resource "aws_lb_listener" "myelblistener" {
  load_balancer_arn = aws_lb.myelb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_target_group.arn
  }
}


## ----------------------------------
## ASG Launch Template

resource "aws_launch_template" "mylaunchtemplate" {
  image_id               = var.ami_type_linux
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykp.id
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_web]
  user_data = base64encode(
    templatefile(
      "user_data.tpl", {
        rds_name = data.terraform_remote_state.state_200data.outputs.rds_cname
      }
    )
  )
  iam_instance_profile {
    name = data.terraform_remote_state.state_000base.outputs.ssm_profile
  }

  tags = merge(
    local.tags, {
      "Name" = "Onboarding2020-ASG-LT"
    }
  )
}


## ----------------------------------
## ASG

resource "aws_autoscaling_group" "myasg" {
  name                = "Onboarding2020-ASG"
  max_size            = var.autoscale_max
  min_size            = var.autoscale_max
  target_group_arns   = [aws_lb_target_group.elb_target_group.arn]
  vpc_zone_identifier = data.terraform_remote_state.state_000base.outputs.subnet_private
  health_check_type   = "EC2"
  launch_template {
    name    = aws_launch_template.mylaunchtemplate.name
    version = "$Default"
  }

  tags = concat(
    [
      {
        key                 = "Name",
        value               = "EC2-Linux"
        propagate_at_launch = true
      }
    ],
    var.extra_tags,
  )
}


## ----------------------------------
## Windows Test Instance

resource "aws_instance" "ec2_windows_test" {
  subnet_id              = data.terraform_remote_state.state_000base.outputs.subnet_public[0]
  vpc_security_group_ids = [data.terraform_remote_state.state_100security.outputs.sg_testing]
  iam_instance_profile   = data.terraform_remote_state.state_000base.outputs.ssm_profile
  instance_type          = var.instance_type
  ami                    = var.ami_type_windows
  key_name               = aws_key_pair.mykp.id

  tags = merge(
    local.tags,
    {
      Name = "EC2-Windows-Test"
    }
  )
}