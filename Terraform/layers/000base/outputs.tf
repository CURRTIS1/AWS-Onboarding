/**
 * # 000base - outputs.tf
 */

output "vpc_id" {
  value       = aws_vpc.main_vpc.id 
  description = "The ID of the main VPC"
}

output "subnet_public" {
  value       = aws_subnet.subnet_Public.*.id
  description = "The ID of the public subnet"
}

output "ssm_profile" {
  value       = aws_iam_instance_profile.ssm_profile.id
  description = "The ID of the ssm profile"
}