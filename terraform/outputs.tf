output "vpc_id" {
  value       = aws_vpc.cloudops.id
  description = "ID of the VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public_a.id
  description = "Public subnet ID"
}

output "private_subnet_id" {
  value       = aws_subnet.private_a.id
  description = "Private subnet ID"
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of the jump host"
}

output "bastion_private_ip" {
  value       = aws_instance.bastion.private_ip
  description = "Private IP of the jump host"
}

output "app_private_ip" {
  value       = aws_instance.app.private_ip
  description = "Private IP of the app server"
}
