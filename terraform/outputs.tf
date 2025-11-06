output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_eip.app_eip.public_ip}:5000"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}
