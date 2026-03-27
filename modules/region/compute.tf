data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_launch_template" "web" {
  name_prefix = "portfolio-${var.region_name}-web-"
  image_id = data.aws_ssm_parameter.ami.value
  instance_type = "t3.micro"

  network_interfaces {
    security_groups = [aws_security_group.web.id]
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }
  // launch_template won't convert base64 automatically
  user_data = base64encode(<<-EOF
    #!/bin/bash
    mkdir -p /var/www/html
    echo "<h1>${var.region_name}</h1>" > /var/www/html/index.html
    cat > /etc/systemd/system/httpserver.service <<'UNIT'
    [Unit]
    Description=Simple HTTP Server
    After=network.target

    [Service]
    ExecStart=/usr/bin/python3 -m http.server 80 --directory /var/www/html
    Restart=always
    User=root

    [Install]
    WantedBy=multi-user.target
    UNIT
    systemctl enable httpserver
    systemctl start httpserver
  EOF
  )
}

resource "aws_autoscaling_group" "web" {
  name                = "portfolio-${var.region_name}-asg"
  min_size            = 1
  desired_capacity    = 1
  max_size            = 3
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  target_group_arns   = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "portfolio-${var.region_name}-web"
    propagate_at_launch = true
  }

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages,
    aws_vpc_endpoint.ec2messages,
  ]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "portfolio-${var.region_name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "portfolio-${var.region_name}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "portfolio-${var.region_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "portfolio-${var.region_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}
