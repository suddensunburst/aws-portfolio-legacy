# show ns
output "portfolio_ns" {
  value = aws_route53_zone.portfolio_sub.name_servers
}

# show the private ip of tokyo main instance
output "tokyo_web_private_ip" {
  value = module.tokyo.web_a_private_ip
}

# show the private ip of osaka main instance
output "osaka_web_private_ip" {
  value = module.osaka.web_a_private_ip
}
