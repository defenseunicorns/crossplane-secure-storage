# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.cpss_vpc.id
  cidr_block              = "10.0.0.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "cpss-public-0"
  }
}

# Route table
resource "aws_route_table" "public_rte" {
  vpc_id = aws_vpc.cpss_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cpss_igw.id
  }

  tags = {
    Name = "cpss-public-rte"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rte.id
}

# Associate the public route table as the VPC's main route table
resource "aws_main_route_table_association" "public_assoc" {
  vpc_id         = aws_vpc.cpss_vpc.id
  route_table_id = aws_route_table.public_rte.id
}
