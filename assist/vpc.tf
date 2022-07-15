# VPC
resource "aws_vpc" "cpss_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "crossplane-secure-storage"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "cpss_igw" {
  vpc_id = aws_vpc.cpss_vpc.id

  tags   = {
    Name = "cpss-igw"
  }
}
