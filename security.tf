# tokyo web security group
resource "aws_security_group" "tokyo_web_sg" {
  name   = "portfolio-web-sg"
  vpc_id = aws_vpc.main.id

  # allow http from alb
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.tokyo_alb_sg.id]
  }

  # allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-web-sg" }
}

# osaka web security group
resource "aws_security_group" "osaka_web_sg" {
  provider = aws.osaka
  name     = "portfolio-osaka-web-sg"
  vpc_id   = aws_vpc.osaka_main.id

  # allow http
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.osaka_alb_sg.id]
  }

  # allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-osaka-web-sg" }
}

# tokyo alb security group
resource "aws_security_group" "tokyo_alb_sg" {
  name   = "portfolio-alb-sg"
  vpc_id = aws_vpc.main.id

  # allow http (80 for redirection)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow https (443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-alb-sg" }
}


# osaka alb security group
resource "aws_security_group" "osaka_alb_sg" {
  provider = aws.osaka
  name     = "osaka-portfolio-alb-sg"
  vpc_id   = aws_vpc.osaka_main.id

  # allow http (80 for redirection)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow https (443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "osaka-portfolio-alb-sg" }
}

# tokyo vpc end point sg
resource "aws_security_group" "tokyo_vpce_sg" {
  name   = "portfolio-vpce-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}


# osaka vpc end point sg
resource "aws_security_group" "osaka_vpce_sg" {
  provider = aws.osaka
  name     = "osaka-portfolio-vpce-sg"
  vpc_id   = aws_vpc.osaka_main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }
}
