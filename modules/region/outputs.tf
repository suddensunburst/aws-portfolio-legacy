output "alb_dns_name" {
    value = aws_lb.main.dns_name
}

output "alb_zone_id" {
    value = aws_lb.main.zone_id
}

output "web_a_private_ip" {
    value = aws_instance.web_a.private_ip
}
