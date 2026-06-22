data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ]
  }
}

resource "aws_instance" "app_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.public_1.id

  key_name = "HELLOE"

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile(
    "${path.module}/userdata/docker.sh",
    {
      frontend_repo = var.frontend_repo
      backend_repo  = var.backend_repo
    }
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-app-server"
    }
  )
}