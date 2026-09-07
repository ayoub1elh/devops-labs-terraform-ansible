# ---------------------------------------------------------------------------
# outputs.tf — Values the learner needs to verify and clean up the stack.
#
# After `make deploy`, terraform prints these automatically. instance_public_ip
# is the address you curl to confirm Nginx is up; instance_id is what you
# search for in the AWS console during cleanup.
# ---------------------------------------------------------------------------

output "instance_public_ip" {
  description = "Public IP of the Nginx EC2 instance. Curl this to verify the web server."
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the Nginx EC2 instance."
  value       = aws_instance.web.public_dns
}

output "instance_id" {
  description = "EC2 instance ID — use this to find the instance in the AWS console and confirm it is terminated during cleanup."
  value       = aws_instance.web.id
}

output "vpc_id" {
  description = "ID of the lab VPC."
  value       = aws_vpc.lab.id
}

output "security_group_id" {
  description = "ID of the web security group."
  value       = aws_security_group.web.id
}
