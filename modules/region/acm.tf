# Request a Cert
resource "aws_acm_certificate" "main" {
  domain_name       = "portfolio.${var.domain_name}"
  validation_method = "DNS"

  tags = { Name = "portfolio-${var.region_name}-cert" }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a CNAME record on Route 53
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# Wait until the validation process completes (otherwise alb fails or so they say)
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
