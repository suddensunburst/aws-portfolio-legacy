# vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "portfolio-vpc"
  }
}

# public subnets
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "portfolio-public-1a" }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "portfolio-public-1c" }
}

# ---- Osaka Region ----

# osaka vpc 10.1.0.0/16
resource "aws_vpc" "osaka_main" {
  provider   = aws.osaka
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "portfolio-vpc-osaka"
  }
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

# tokyo igw
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "portfolio-igw"
  }
}

# osaka igw
resource "aws_internet_gateway" "osaka" {
  provider = aws.osaka
  vpc_id   = aws_vpc.osaka_main.id

  tags = {
    Name = "portfolio-igw-osaka"
  }
}

# tokyo route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "portfolio-public-rt" }
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
