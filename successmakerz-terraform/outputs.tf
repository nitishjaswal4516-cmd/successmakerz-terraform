output "instance_public_ip" {

  value = aws_instance.app_server.public_ip
}

output "instance_id" {

  value = aws_instance.app_server.id
}

output "instance_public_dns" {

  value = aws_instance.app_server.public_dns
}
output "elastic_ip" {
  value = aws_eip.app_eip.public_ip
}