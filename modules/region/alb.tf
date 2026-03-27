resource "aws_lb" "main" {
  name               = "portfolio-${var.region_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_c.id]

  tags = { Name = "portfolio-${var.region_name}-alb" }
}

# target group
resource "aws_lb_target_group" "main" {
  name        = "portfolio-${var.region_name}-tg"
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
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
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

# https listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# attach to web instances
resource "aws_lb_target_group_attachment" "web_a" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web_a.id
}

resource "aws_lb_target_group_attachment" "web_c" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web_c.id
}
