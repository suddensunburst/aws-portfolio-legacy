# vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "portfolio-tokyo-vpc" }
}

# public subnets
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "portfolio-tokyo-public-1a" }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "portfolio-tokyo-public-1c" }
}

# private subnets
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "portfolio-tokyo-private-1a" }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "portfolio-tokyo-private-1c" }
}

# ---- Osaka Region ----

# osaka vpc 10.1.0.0/16
resource "aws_vpc" "osaka_main" {
  provider             = aws.osaka
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "portfolio-osaka-vpc" }
}

# osaka public subnets
resource "aws_subnet" "osaka_public_3a" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-northeast-3a"
  tags              = { Name = "portfolio-osaka-public-3a" }
}

resource "aws_subnet" "osaka_public_3c" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-northeast-3c"
  tags              = { Name = "portfolio-osaka-public-3c" }
}

# osaka private subnets
resource "aws_subnet" "osaka_private_3a" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "ap-northeast-3a"
  tags              = { Name = "portfolio-osaka-private-3a" }
}

resource "aws_subnet" "osaka_private_3c" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "ap-northeast-3c"
  tags              = { Name = "portfolio-osaka-private-3c" }
}

# tokyo igw
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "portfolio-tokyo-igw" }
}

# osaka igw
resource "aws_internet_gateway" "osaka" {
  provider = aws.osaka
  vpc_id   = aws_vpc.osaka_main.id

  tags = { Name = "portfolio-osaka-igw" }
}

# tokyo route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "portfolio-tokyo-public-rt" }
}

# associate the tokyo route table to the public subnet 1a
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# associate the tokyo route table to the public subnet 1c
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# osaka route table
resource "aws_route_table" "osaka_public" {
  provider = aws.osaka
  vpc_id   = aws_vpc.osaka_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.osaka.id
  }

  tags = { Name = "portfolio-osaka-public-rt" }
}

# associate the osaka route table to the public subnet 3a
resource "aws_route_table_association" "osaka_public_3a" {
  provider       = aws.osaka
  subnet_id      = aws_subnet.osaka_public_3a.id
  route_table_id = aws_route_table.osaka_public.id
}

# associate the osaka route table to the public subnet 3c
resource "aws_route_table_association" "osaka_public_3c" {
  provider       = aws.osaka
  subnet_id      = aws_subnet.osaka_public_3c.id
  route_table_id = aws_route_table.osaka_public.id
}

# tokyo ssm endpoints
resource "aws_vpc_endpoint" "tokyo_ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids = [aws_security_group.tokyo_vpce_sg.id]

  tags = { Name = "portfolio-vpce-tokyo-ssm" }
}

resource "aws_vpc_endpoint" "tokyo_ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids = [aws_security_group.tokyo_vpce_sg.id]

  tags = { Name = "portfolio-vpce-tokyo-ssmmessages" }
}

resource "aws_vpc_endpoint" "tokyo_ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids = [aws_security_group.tokyo_vpce_sg.id]

  tags = { Name = "portfolio-vpce-tokyo-ec2messages" }
}

# osaka ssm endpoints
resource "aws_vpc_endpoint" "osaka_ssm" {
  provider            = aws.osaka
  vpc_id              = aws_vpc.osaka_main.id
  service_name        = "com.amazonaws.ap-northeast-3.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.osaka_private_3a.id, aws_subnet.osaka_private_3c.id]
  security_group_ids = [aws_security_group.osaka_vpce_sg.id]

  tags = { Name = "portfolio-vpce-osaka-ssm" }
}

resource "aws_vpc_endpoint" "osaka_ssmmessages" {
  provider            = aws.osaka
  vpc_id              = aws_vpc.osaka_main.id
  service_name        = "com.amazonaws.ap-northeast-3.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.osaka_private_3a.id, aws_subnet.osaka_private_3c.id]
  security_group_ids = [aws_security_group.osaka_vpce_sg.id]

  tags = { Name = "portfolio-vpce-osaka-ssmmessages" }
}

resource "aws_vpc_endpoint" "osaka_ec2messages" {
  provider            = aws.osaka
  vpc_id              = aws_vpc.osaka_main.id
  service_name        = "com.amazonaws.ap-northeast-3.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.osaka_private_3a.id, aws_subnet.osaka_private_3c.id]
  security_group_ids = [aws_security_group.osaka_vpce_sg.id]

  tags = { Name = "portfolio-vpce-osaka-ec2messages" }
}

