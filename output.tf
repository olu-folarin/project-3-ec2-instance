output "aws_security_group_details" {
  value = aws_security_group.http_server_secg
}

output "aws_ec2_instance_details" {
  value = aws_instance.http_server
}

output "aws_ec2_instance_pubdns_details" {
  value = aws_instance.http_server.public_dns
}