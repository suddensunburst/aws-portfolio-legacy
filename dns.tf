# dns: make "portfolio" subdomain zone
resource "aws_route53_zone" "portfolio_sub" {
  name = "portfolio.${var.main_domain}"
}

# tokyo record (primary)
resource "aws_route53_record" "portfolio_primary" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.${var.main_domain}"
  type    = "A"

  # use an alias when using alb (free and fast)
  alias {
    name                   = module.tokyo.alb_dns_name
    zone_id                = module.tokyo.alb_zone_id
    evaluate_target_health = true
  }

  # failover stuff
  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "tokyo"
}

# osaka record (secondary)
resource "aws_route53_record" "osaka_failover" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.${var.main_domain}"
  type    = "A"

  # specify alb as an alias
  alias {
    name                   = module.osaka.alb_dns_name
    zone_id                = module.osaka.alb_zone_id
    evaluate_target_health = true
  }

  # failover stuff
  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "osaka"
}

# delegate portfolio subdomain to route 53
resource "cloudflare_record" "portfolio_ns" {
  count   = 4
  zone_id = var.cloudflare_zone_id
  name    = "portfolio"
  content = aws_route53_zone.portfolio_sub.name_servers[count.index]
  type    = "NS"
  ttl     = 60
}