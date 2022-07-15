resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.cpss_vpc.id

  tags = {
    Name = "cpss-default-sg"
  }
}

resource "aws_security_group" "cpss_bastion_sg" {
  name   = "cpss-bastion-sg"
  vpc_id = aws_vpc.cpss_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cpss-bastion-sg"
  }
}

resource "aws_security_group" "cpss_k8s_sg" {
  name = "cpss-k8s-sg"
  vpc_id = aws_vpc.cpss_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cpss-k8s-sg"
  }
}