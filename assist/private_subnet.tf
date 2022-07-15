# NAT gateway
resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "cpss-nat-gw"
  }
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.cpss_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "cpss-private"
  }
}

# Route table for the private subnet
resource "aws_route_table" "private_rte" {
  vpc_id = aws_vpc.cpss_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "cpss-private-rte"
  }
}

# Associate the private route table with the private subnets
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rte.id
}

