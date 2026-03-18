# tokyo latest amazon linux 2023 id
data "aws_ssm_parameter" "amzn2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# launch tokyo web server 1a
resource "aws_instance" "tokyo_web_1a" {
  ami           = data.aws_ssm_parameter.amzn2023_ami.value
  instance_type = "t3.micro"

  # private subnet 1a
  subnet_id = aws_subnet.private_1a.id

  # attach security grp
  vpc_security_group_ids = [aws_security_group.tokyo_web_sg.id]

  # init sh (python webserver)
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www/html
    echo "<h1>tokyo 1a</h1>" > /var/www/html/index.html
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

  tags = { Name = "portfolio-tokyo-web-1a" }

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  depends_on = [
    aws_vpc_endpoint.tokyo_ssm,
    aws_vpc_endpoint.tokyo_ssmmessages,
    aws_vpc_endpoint.tokyo_ec2messages,
  ]
}


# launch tokyo web server 1c
resource "aws_instance" "tokyo_web_1c" {
  ami           = data.aws_ssm_parameter.amzn2023_ami.value
  instance_type = "t3.micro"

  # private subnet 1c
  subnet_id = aws_subnet.private_1c.id

  # attach security grp
  vpc_security_group_ids = [aws_security_group.tokyo_web_sg.id]

  # init sh
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www/html
    echo "<h1>tokyo 1c</h1>" > /var/www/html/index.html
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

  tags = { Name = "portfolio-tokyo-web-1c" }

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  depends_on = [
    aws_vpc_endpoint.tokyo_ssm,
    aws_vpc_endpoint.tokyo_ssmmessages,
    aws_vpc_endpoint.tokyo_ec2messages,
  ]
}


# osaka latest amazon linux 2023 id
data "aws_ssm_parameter" "osaka_amzn2023_ami" {
  provider = aws.osaka
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# launch osaka web server
resource "aws_instance" "osaka_web_3a" {
  provider      = aws.osaka
  ami           = data.aws_ssm_parameter.osaka_amzn2023_ami.value
  instance_type = "t3.micro"

  # private subnet 3a
  subnet_id = aws_subnet.osaka_private_3a.id

  # attach security grp
  vpc_security_group_ids = [aws_security_group.osaka_web_sg.id]

  # init sh
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www/html
    echo "<h1>osaka 3a</h1>" > /var/www/html/index.html
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

  tags = { Name = "portfolio-osaka-web-3a" }

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  depends_on = [
    aws_vpc_endpoint.osaka_ssm,
    aws_vpc_endpoint.osaka_ssmmessages,
    aws_vpc_endpoint.osaka_ec2messages,
  ]
}

resource "aws_instance" "osaka_web_3c" {
  provider      = aws.osaka
  ami           = data.aws_ssm_parameter.osaka_amzn2023_ami.value
  instance_type = "t3.micro"

  # private subnet 3c
  subnet_id = aws_subnet.osaka_private_3c.id

  # attach security grp
  vpc_security_group_ids = [aws_security_group.osaka_web_sg.id]

  # init sh
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www/html
    echo "<h1>osaka 3c</h1>" > /var/www/html/index.html
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

  tags = { Name = "portfolio-osaka-web-3c" }

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  depends_on = [
    aws_vpc_endpoint.osaka_ssm,
    aws_vpc_endpoint.osaka_ssmmessages,
    aws_vpc_endpoint.osaka_ec2messages,
  ]
}
