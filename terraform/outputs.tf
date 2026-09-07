# outputs.tf — Values exposed to the GitHub Actions jobs and to local runs.
# The smoke-test job consumes `public_ip` through the workflow's job outputs.

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the web instance (used by the smoke test)"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the web instance"
  value       = aws_instance.web.public_dns
}

output "ssh_command" {
  description = "Ready-to-paste SSH command"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.web.public_ip}"
}

output "inventory_file" {
  description = "Path of the Terraform-generated static Ansible inventory"
  value       = local_file.ansible_inventory.filename
}
