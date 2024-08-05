data "aws_route53_zone" "dogs" {
  name = "${var.subdomain}.${var.top_level_domain}"
}

variable "subdomain" {
  type = string
}

variable "top_level_domain" {
  type = string
}

resource "aws_acm_certificate" "dogs" {
  provider = aws.useast1

  domain_name = "${var.subdomain}.${var.top_level_domain}"
  subject_alternative_names = [
    "img.${var.subdomain}.${var.top_level_domain}",
  ]
  validation_method = "DNS"
}

resource "aws_route53_record" "dogs_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.dogs.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.dogs.zone_id
}