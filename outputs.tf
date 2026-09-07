# outputs.tf — the few values a learner actually needs after apply:
# how to reach the server, what it is called, and how to SSH into it.

output "instance_public_ip" {
  description = "Public IP address of the Nginx instance. Use it for curl and SSH."
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "EC2 instance ID — handy for the AWS console and for CLI checks."
  value       = aws_instance.web.id
}

output "ssh_command" {
  description = "Ready-to-copy SSH command (uses the default ubuntu user and the private key matching your public key)."
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.web.public_ip}"
}
