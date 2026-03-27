# web security group
resource "aws_security_group" "web" {
  name   = "portfolio-${var.region_name}-web-sg"
  vpc_id = aws_vpc.main.id

  # allow http from alb
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-${var.region_name}-web-sg" }
}

# alb security group
resource "aws_security_group" "alb" {
  name   = "portfolio-${var.region_name}-alb-sg"
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

  tags = { Name = "portfolio-${var.region_name}-alb-sg" }
}

# vpc end point sg
resource "aws_security_group" "vpce" {
  name   = "portfolio-${var.region_name}-vpce-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}
