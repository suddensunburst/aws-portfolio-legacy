# show ns
output "portfolio_ns" {
  value = aws_route53_zone.portfolio_sub.name_servers
}

