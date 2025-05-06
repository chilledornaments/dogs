data "aws_route53_zone" "dogs" {
  name = var.domain
}

resource "aws_acm_certificate" "images" {
  provider = aws.useast1

  domain_name               = "img.${var.domain}"
  subject_alternative_names = []
  validation_method         = "DNS"
}

resource "aws_route53_record" "images_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.images.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 3600
  type            = each.value.type
  zone_id         = local.route53_zone_id
}

resource "aws_acm_certificate" "api" {
  domain_name       = "api.${var.domain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "api_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 3600
  type            = each.value.type
  zone_id         = local.route53_zone_id
}

resource "time_sleep" "wait_for_acm" {
  create_duration = "30s"

  depends_on = [
    aws_route53_record.api_acm_validation
  ]
}
