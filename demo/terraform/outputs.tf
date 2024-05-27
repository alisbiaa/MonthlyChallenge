output "lab_instance_public_ips" {
  description = "The public IP addresses of the lab instances"
  value       = aws_instance.lab_instance[*].public_ip
}
