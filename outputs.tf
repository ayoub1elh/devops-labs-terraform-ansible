# outputs.tf — values printed after each apply. In CI these are logged by the
# workflow so you can grab the instance URL without ever opening the console.

output "instance_public_ip" {
  description = "Public IP of the Nginx EC2 instance."
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the Nginx EC2 instance."
  value       = aws_instance.web.public_dns
}

output "nginx_url" {
  description = "URL to verify Nginx is serving."
  value       = "http://${aws_instance.web.public_dns}"
}

output "vpc_id" {
  description = "ID of the lab VPC (useful for cleanup double-checks)."
  value       = aws_vpc.main.id
}
