########################################
# Route53 + ACM for site.tawanperry.top
########################################

locals {
  root_domain = "tawanperry.top"
  site_fqdn   = "site.tawanperry.top"
}

# Existing hosted zone for tawanperry.top
data "aws_route53_zone" "root" {
  name         = "${local.root_domain}."
  private_zone = false
}

# Request ACM certificate for site.tawanperry.top
resource "aws_acm_certificate" "app_cert" {
  domain_name       = local.site_fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "app1-acm-cert"
    Owner   = "Tawan"
    Planet  = "terraform-training"
    Service = "application1"
  }
}

# DNS record(s) for ACM validation
resource "aws_route53_record" "app_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.root.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  # allow Terraform to take over an existing validation record
  allow_overwrite = true
}

# Tell ACM to validate using the Route53 records
resource "aws_acm_certificate_validation" "app_cert_validation" {
  certificate_arn = aws_acm_certificate.app_cert.arn

  validation_record_fqdns = [
    for record in aws_route53_record.app_cert_validation : record.fqdn
  ]
}

# A-record alias: site.tawanperry.top -> ALB
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.site_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.app1_alb.dns_name
    zone_id                = aws_lb.app1_alb.zone_id
    evaluate_target_health = true
  }

  # allow Terraform to take over an existing A record
  allow_overwrite = true
}
