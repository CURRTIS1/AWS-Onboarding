/**
 * # 000base - outputs.tf
 */

 output "vpc_id" {
  value       = aws_vpc.main_vpc.id 
  description = "The ID of the main VPC"
}