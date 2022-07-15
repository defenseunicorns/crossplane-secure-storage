# Make the bastion accessible
resource "aws_network_interface" "bastion_eni" {
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.cpss_bastion_sg.id]

  tags = {
    Name = "cpss-bastion-eni"
  }
}

resource "aws_instance" "cpss_bastion" {
  instance_type = var.bastion_type
  ami           = var.amis[var.aws_region]

  key_name      = aws_key_pair.generated_bastion_key.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.bastion_eni.id
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp2"
    volume_size = 100
  }

  tags = {
    Name = "cpss-bastion"
  }
}
