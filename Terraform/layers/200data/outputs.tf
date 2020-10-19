/**
 * # 200data - outputs.tf
 */

 output "rds_cname" {
  value       = aws_db_instance.myrdsinstance.address
  description = "The ID of the RDS instancs"
}