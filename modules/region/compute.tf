# latest amazon linux 2023 id
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# launch web server a
resource "aws_instance" "web_a" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # init sh (python httpserver)
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www/html
    echo "<h1>${var.region_name} a</h1>" > /var/www/html/index.html
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

  iam_instance_profile = var.iam_instance_profile
  tags = { Name = "portfolio-${var.region_name}-web-a" }

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages,
    aws_vpc_endpoint.ec2messages,
  ]
}

# launch web server c
resource "aws_instance" "web_c" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private_c.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # init sh
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www/html
    echo "<h1>${var.region_name} c</h1>" > /var/www/html/index.html
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

  iam_instance_profile = var.iam_instance_profile
  tags = { Name = "portfolio-${var.region_name}-web-c" }

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages,
    aws_vpc_endpoint.ec2messages,
  ]
}
