resource "aws_acm_certificate" "ecs_domain_certificate" {
  domain_name       = "*.${var.ecs_domain_name}"
  validation_method = "DNS"
  tags = {
    Name            = "${var.ecs_cluster_name}-certificate"
    Environment     = var.environment
  }
}

# Hosting zone create
data "aws_route53_zone" "ecs_domain" {
  name          = var.ecs_domain_name
  private_zone  = false
}

resource "aws_route53_record" "ecs_cert_validation_record" {
  name              = element(aws_acm_certificate.ecs_domain_certificate.domain_validation_options.*.resource_record_name, 0)
  type              = element(aws_acm_certificate.ecs_domain_certificate.domain_validation_options.*.resource_record_type, 0)
  records           = aws_acm_certificate.ecs_domain_certificate.domain_validation_options.*.resource_record_value
  zone_id           = data.aws_route53_zone.ecs_domain.zone_id
  ttl               = 60
  allow_overwrite   = true

  depends_on = [
    aws_acm_certificate.ecs_domain_certificate,
    data.aws_route53_zone.ecs_domain
  ]
}

resource "aws_acm_certificate_validation" "ecs_domain_cert_validation" {
  certificate_arn           = aws_acm_certificate.ecs_domain_certificate.arn
  validation_record_fqdns   = [aws_route53_record.ecs_cert_validation_record.fqdn]
}