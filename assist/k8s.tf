resource "aws_instance" "cpss_k8s" {
  instance_type          = var.k8s_type
  ami                    = var.amis[var.aws_region]

  key_name               = aws_key_pair.generated_k8s_key.key_name

  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.cpss_k8s_sg.id]

  root_block_device {
    encrypted   = true
    volume_type = "gp2"
    volume_size = 100
  }

  tags = {
    Name = "cpss-k8s"
  }
}
