# elastic-ip.tf

resource "aws_eip" "app_eip" {
  domain = "vpc"

  tags = {
    Name = "successmakerz-eip"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = aws_eip.app_eip.id
}