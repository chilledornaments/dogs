data "aws_route53_zone" "dogs" {
  name = "dogs.chilledornaments.com"
}

resource "aws_acm_certificate" "dogs" {
  provider = aws.useast1

  domain_name = "dogs.chilledornaments.com"
  subject_alternative_names = [
    "img.dogs.chilledornaments.com",
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