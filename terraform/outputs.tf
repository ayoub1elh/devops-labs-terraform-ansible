# outputs.tf — connection details for the instance Terraform creates.
#
# Note: these are for YOUR convenience (checking IPs, curling the site). The
# Ansible inventory no longer reads these outputs — the aws_ec2 plugin
# discovers the instances directly from the AWS API using the Environment tag.

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "ssh_command" {
  description = "Command to SSH into the instance (key path may differ on your machine)"
  value       = "ssh -i ~/.ssh/devops-labs ubuntu@${aws_instance.web.public_ip}"
}
