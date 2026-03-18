# show ns
output "portfolio_ns" {
  value = aws_route53_zone.portfolio_sub.name_servers
}

# show the private ip of tokyo main instance
output "tokyo_web_private_ip" {
  value = aws_instance.tokyo_web_1a.private_ip
}

# show the private ip of osaka main instance
output "osaka_web_private_ip" {
  value = aws_instance.osaka_web_3a.private_ip
}
