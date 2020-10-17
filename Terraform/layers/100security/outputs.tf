/**
 * # 100security - outputs.tf


  output "SG_ALB" {
  value       = aws_security_group.SG_ALB.id 
  description = "The ID of the Application Loadbalancer Security Group"
}

  output "SG_Web" {
  value       = aws_security_group.SG_Web.id 
  description = "The ID of the WebServer Group"
}

  output "SG_RDS" {
  value       = aws_security_group.SG_RDS.id 
  description = "The ID of the RDS Group"
}
 */

output "SG_Web" {
  value       = aws_security_group.SG_Web.id 
  description = "The ID of the WebServer Group"
}