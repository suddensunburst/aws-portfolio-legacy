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

