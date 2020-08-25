resource "aws_instance" "ec2_instance" {
  ami           = var.AMI_type
  instance_type = var.instance_type
}