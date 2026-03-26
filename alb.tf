# TOKYO
# ALB Tokyo
resource "aws_lb" "tokyo_alb" {
  name               = "portfolio-tokyo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tokyo_alb_sg.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  tags = {
    Name = "portfolio-tokyo-alb"
  }
}

# target group Tokyo
resource "aws_lb_target_group" "tokyo_tg" {
  name        = "portfolio-tokyo-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }
}

# redirect to https
resource "aws_lb_listener" "tokyo_http_redirect" {
  load_balancer_arn = aws_lb.tokyo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301" # force https
    }
  }
}

# https listener (443)
resource "aws_lb_listener" "tokyo_https" {
  load_balancer_arn = aws_lb.tokyo_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tokyo_tg.arn
  }
}

# attach to tokyo web instances
resource "aws_lb_target_group_attachment" "tokyo_1a" {
  target_group_arn = aws_lb_target_group.tokyo_tg.arn
  target_id        = aws_instance.tokyo_web_1a.id
}

resource "aws_lb_target_group_attachment" "tokyo_1c" {
  target_group_arn = aws_lb_target_group.tokyo_tg.arn
  target_id        = aws_instance.tokyo_web_1c.id
}

# OSAKA
# ALB Osaka
resource "aws_lb" "osaka_alb" {
  provider           = aws.osaka
  name               = "portfolio-osaka-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.osaka_alb_sg.id]
  subnets            = [aws_subnet.osaka_public_3a.id, aws_subnet.osaka_public_3c.id]

  tags = {
    Name = "portfolio-osaka-alb"
  }
}

# target group Osaka
resource "aws_lb_target_group" "osaka_tg" {
  provider    = aws.osaka
  name        = "portfolio-osaka-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.osaka_main.id
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }
}

# redirect to https
resource "aws_lb_listener" "osaka_http_redirect" {
  provider          = aws.osaka
  load_balancer_arn = aws_lb.osaka_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301" # force https
    }
  }
}

# https listener (443)
resource "aws_lb_listener" "osaka_https" {
  provider          = aws.osaka
  load_balancer_arn = aws_lb.osaka_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.osaka_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.osaka_tg.arn
  }
}

# attach to osaka web instances
resource "aws_lb_target_group_attachment" "osaka_3a" {
  provider         = aws.osaka
  target_group_arn = aws_lb_target_group.osaka_tg.arn
  target_id        = aws_instance.osaka_web_3a.id
}

resource "aws_lb_target_group_attachment" "osaka_3c" {
  provider         = aws.osaka
  target_group_arn = aws_lb_target_group.osaka_tg.arn
  target_id        = aws_instance.osaka_web_3c.id
}