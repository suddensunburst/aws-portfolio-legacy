# vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "portfolio-${var.region_name}-vpc" }
}

# public subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = var.public_subnet_a_az
  tags              = { Name = "portfolio-${var.region_name}-public-a" }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_c_cidr
  availability_zone = var.public_subnet_c_az
  tags              = { Name = "portfolio-${var.region_name}-public-c" }
}

# private subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.private_subnet_a_az
  tags              = { Name = "portfolio-${var.region_name}-private-a" }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_c_cidr
  availability_zone = var.private_subnet_c_az
  tags              = { Name = "portfolio-${var.region_name}-private-c" }
}

# IGW
resource "aws_internet_gateway" "main" {
  vpc_id   = aws_vpc.main.id
  tags = { Name = "portfolio-${var.region_name}-igw" }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "portfolio-${var.region_name}-public-rt" }
}

# associate the route table to the public subnet a
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# associate the route table to the public subnet c
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

# ssm endpoints
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region_code}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  security_group_ids = [aws_security_group.vpce.id]
  tags = { Name = "portfolio-vpce-${var.region_name}-ssm" }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region_code}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  security_group_ids = [aws_security_group.vpce.id]
  tags = { Name = "portfolio-vpce-${var.region_name}-ssmmessages" }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region_code}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  security_group_ids = [aws_security_group.vpce.id]
  tags = { Name = "portfolio-vpce-${var.region_name}-ec2messages" }
}
