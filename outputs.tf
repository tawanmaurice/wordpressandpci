#################
# Stack Outputs
#################

# Only keep the RDS endpoint here.
# lb_dns_name and asg_name are already defined in other files.

output "rds_endpoint" {
  description = "Endpoint of the WordPress RDS instance"
  value       = aws_db_instance.wp.address
}
