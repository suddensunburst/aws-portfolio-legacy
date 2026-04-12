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
set -e
mkdir -p /app /tmp/wheels
aws s3 cp s3://portfolio-app-${data.aws_caller_identity.current.account_id}-${var.region_name}/app/main.py /app/main.py
aws s3 sync s3://portfolio-app-${data.aws_caller_identity.current.account_id}-${var.region_name}/wheels/ /tmp/wheels/
python3 -m ensurepip
python3 -m pip install --no-index --find-links /tmp/wheels flask boto3


# IMDSv2: まずトークンを取得
TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token \
  -H "X-aws-ec2-metadata-token-ttl-seconds:60")

# トークンを使ってリージョンを取得
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region \
  -H "X-aws-ec2-metadata-token: $TOKEN")

cat > /etc/systemd/system/portfolio.service <<UNIT
[Unit]
Description=Portfolio Flask App
After=network.target

[Service]
Environment=AWS_DEFAULT_REGION=$${REGION}
ExecStart=/usr/bin/python3 /app/main.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
UNIT

systemctl enable portfolio
systemctl start portfolio
EOF
)
}

resource "aws_autoscaling_group" "web" {
  name                = "portfolio-${var.region_name}-asg"
  min_size            = 2
  desired_capacity    = 2
  max_size            = 3
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  target_group_arns   = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "portfolio-${var.region_name}-web"
    propagate_at_launch = true
  }

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages,
    aws_vpc_endpoint.ec2messages,
    aws_vpc_endpoint.s3,
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
